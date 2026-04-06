class ClassSchedule < ApplicationRecord
  belongs_to :class_type
  belongs_to :instructor, class_name: "User"
  has_many :bookings, dependent: :destroy
  has_many :active_bookings, -> { active }, class_name: "Booking"

  GRACE_PERIOD_MINUTES = 20
  BOOKING_OPEN_HOUR = 19
  ADMIN_OPEN_HOUR =21 

  enum :modality, { gi: 0, nogi: 1 }

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than: 0 }
  scope :active, -> { where(cancelled: false) }

  scope :matching_schedule, ->(days, time_string) {
    where("strftime('%w', starts_at, 'localtime') IN (?)", days.map(&:to_s))
      .where("strftime('%H:%M', starts_at, 'localtime') = ?", time_string)
  }

  scope :for_date, ->(date) {
      where(starts_at: date.beginning_of_day..date.end_of_day).order(:starts_at)
    }

  scope :dashboard_upcoming, -> {
    now = Time.zone.now
    start_time = now - GRACE_PERIOD_MINUTES.minutes

    end_time = if now.hour >= BOOKING_OPEN_HOUR
                  (Date.tomorrow + 1.day).end_of_day
                else
                  Date.tomorrow.end_of_day
                end
    where(starts_at: start_time..end_time).order(starts_at: :asc)
  }

  scope :past_logical, -> { 
    where("starts_at < ?", Time.zone.now).order(starts_at: :desc) 
    }

  scope :visible_for, ->(user) {
    return all if user.admin?
    return all if user.try(:drop_in_active_today?) || user.try(:unused_tickets?)

    where(class_type: user.bookable_class_types)
  }
  scope :for_range, ->(start_date, end_date) {
    where(starts_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  after_update_commit :broadcast_cancellation, if: :saved_change_to_cancelled?

  # Show modality in the UI if it's not nil(for bjj gi or nogi)
  def show_modality?
    modality.present?
  end

  # --- TIME LOGIC ---
  def ends_at
    starts_at + duration_minutes.minutes
  end

  def date
    starts_at.to_date
  end

  def booking_opens_at
    (starts_at.to_date - 1.day).in_time_zone.change(hour: BOOKING_OPEN_HOUR, min: 0, sec: 0)
  end

  def booking_window_open?
    Time.current >= booking_opens_at
  end

  def in_grace_period?
    now = Time.current
    now >= starts_at && now <= (starts_at + GRACE_PERIOD_MINUTES.minutes)
  end

  def past_grace_period?
    Time.current > (starts_at + GRACE_PERIOD_MINUTES.minutes)
  end

  def upcoming_lock?
    !past? && !booking_window_open?
  end

  def status_for(user)
    return :past if past?
    return :unauthorized unless user.authorized_for?(class_type)
    return :full if full? && !user.admin?
    return :open if booking_window_open?
    :upcoming
  end

  def self.logical_today
    Time.current.hour >= ADMIN_OPEN_HOUR ? Date.tomorrow : Date.current
  end

  # --- SPOTS LOGIC ---
  def spots_left
    capacity - active_bookings_count
  end

  def full?
    spots_left <= 0
  end

  # Helper to show in the UI: "18:30 - 19:30"
  def time_range
    "#{starts_at.strftime('%l:%M %p').strip} - #{ends_at.strftime('%l:%M %p').strip}"
  end

  def active_bookings_list
    bookings.to_a.select { |b| b.confirmed? || b.attended? }
  end

  def fresh_active_bookings
    bookings.where(status: [:confirmed, :attended]).order(:created_at)
  end

  def active_bookings_count
    bookings.to_a.count { |b| b.confirmed? || b.attended? }
  end

  def attended_bookings_count
    bookings.to_a.count(&:attended?)
  end

  def blocked_bookings_count
    bookings.to_a.count(&:blocked?).size
  end

  # --- THE MAGIC: BULK GENERATOR ---
  # This method receives:
  # - schedule_params: { days: [1, 3], time: "18:30" } (Monday=1, Wednesday=3)
  # - range: Date.today..3.months.from_now
  # - fixed attributes: instructor_id, class_type_id, etc.

  def self.bulk_schedule(schedule_params, date_range, attributes)
    # Array to save the records before inserting (Bulk Insert is faster)
    classes_to_create = []

    # Selected days (e.g.: [1, 3] for Mon/Wed)
    target_days = schedule_params[:days].map(&:to_i)
    # Hora base (ej: "18:30")
    base_time = Time.zone.parse(schedule_params[:time])

    now = Time.current

    date_range.each do |date|
      # If the current day matches the desired days (e.g.: is Monday?)
      if target_days.include?(date.wday)
        # Construct the exact date-time by combining the date from the loop with the base time
        start_datetime = date.in_time_zone.change(hour: base_time.hour, min: base_time.min)

        classes_to_create << attributes.merge(
          starts_at: start_datetime,
          created_at: now,
          updated_at: now
          )
      end
    end

    # insert_all create hundreds of records at once
    if classes_to_create.any?
      insert_all(classes_to_create)
    end

    classes_to_create.count
  end
end

private

def broadcast_cancellation
  broadcast_replace_to "schedule_#{id}",
                       target: "universal_card_#{id}",
                       partial: "class_schedules/partials/class_card_universal",
                       locals: { schedule: self, user: nil, context: :dashboard }
  broadcast_replace_to "schedule_#{id}",
                       target: "action_button_schedule_#{id}",
                       partial: "class_schedules/partials/action_button",
                       locals: { schedule: self, user: nil }
end
