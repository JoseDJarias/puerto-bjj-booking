class ClassSchedule < ApplicationRecord
  belongs_to :class_type
  belongs_to :instructor, class_name: "User"
  has_many :bookings

  has_many :active_bookings, -> { active }, class_name: "Booking"

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than: 0 }

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current).order(starts_at: :desc) }
  scope :active, -> { where(cancelled: false) }
  # Booking day rolls at 23:00: after 11 PM user sees next calendar day's classes.
  scope :for_booking_today, -> {
    booking_date = Time.current.hour >= 23 ? Date.current + 1.day : Date.current
    start_bound = [Time.current, booking_date.beginning_of_day].max
    where(starts_at: start_bound..booking_date.end_of_day).order(:starts_at)
  }

  scope :for_range, ->(start_date, end_date) {
    where(starts_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  # --- TIME LOGIC ---
  def ends_at
    starts_at + duration_minutes.minutes
  end

  def date
    starts_at.to_date
  end

# --- SPOTS LOGIC ---
  def spots_left
    capacity - active_bookings.count
  end
  
  def full?
    spots_left <= 0
  end
  
  # Helper to show in the UI: "18:30 - 19:30"
  def time_range
    "#{starts_at.strftime('%l:%M %p').strip} - #{ends_at.strftime('%l:%M %p').strip}"
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
