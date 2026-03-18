class ClassSchedule < ApplicationRecord
  belongs_to :class_type
  belongs_to :instructor, class_name: "User"
  has_many :bookings, dependent: :destroy
  has_many :active_bookings, -> { active }, class_name: "Booking"

  GRACE_PERIOD_MINUTES = 20
  BOOKING_OPEN_HOUR = 20

  enum :modality, { gi: 0, nogi: 1 }

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than: 0 }
  scope :active, -> { where(cancelled: false) }
  # app/models/class_schedule.rb
  scope :matching_schedule, ->(days, time_string) {
    # Añadimos 'localtime' para que SQLite convierta de UTC a tu hora antes de comparar
    where("strftime('%w', starts_at, 'localtime') IN (?)", days.map(&:to_s))
      .where("strftime('%H:%M', starts_at, 'localtime') = ?", time_string)
  }
  # Booking day rolls at 20:00: after 11 PM user sees next calendar day's classes.
  def self.operative_date
    Time.zone.now.hour >= BOOKING_OPEN_HOUR ? Date.tomorrow : Date.current
  end

  # Class schedule index Classes from date.beginning_of_day to date.end_of_day
  scope :for_date, ->(date) {
      where(starts_at: date.beginning_of_day..date.end_of_day).order(:starts_at)
    }

    # Dashboard show Classes from (now - grace period) to end_time, to be visible during the 20 min grace period.
    scope :dashboard_upcoming, -> {
      now = Time.zone.now
      start_time = now - GRACE_PERIOD_MINUTES.minutes

      end_time = if now.hour >= BOOKING_OPEN_HOUR
                   (Date.tomorrow + 1.day).beginning_of_day + 12.hours
                 else
                   Date.tomorrow.beginning_of_day + 12.hours
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
    Time.current.hour >= BOOKING_OPEN_HOUR ? Date.tomorrow : Date.current
  end

# --- SPOTS LOGIC ---
  def spots_left
    capacity - active_bookings_count
  end
  
  def full?
    spots_left=1
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
    base_time = Time.parse(schedule_params[:time])

    # Iterate day by day in the range
    date_range.each do |date|
      # If the current day matches the desired days (e.g.: is Monday?)
      if target_days.include?(date.wday)
        # Construct the exact date-time by combining the date from the loop with the base time
        start_datetime = date.to_time.change(hour: base_time.hour, min: base_time.min)

        classes_to_create << attributes.merge(starts_at: start_datetime)
      end
    end

    # Rails 8: insert_all is super efficient to create hundreds of records at once
    if classes_to_create.any?
      insert_all(classes_to_create)
    end
    
    classes_to_create.count
  end
end
