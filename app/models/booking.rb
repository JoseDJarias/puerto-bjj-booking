class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :class_schedule
  
  # Audit tracking: Who made the last action?
  belongs_to :changed_by, class_name: "User", optional: true

    # --- ROBUST STATES ---
    # confirmed: Occupies space (Standard booking)
    # cancelled_user: The user cancelled (Releases space)
    # cancelled_admin: The admin cancelled (Releases space)
    # attended: Already attended (Occupies space in the history)
    # no_show: Didn't show up (Releases space or marks for punishment)
  enum :status, { 
    confirmed: 0, 
    cancelled_user: 1, 
    cancelled_admin: 2, 
    attended: 3, 
    no_show: 4 
  }

  # --- SCOPES ---
  # Defines which states "occupy space" on the tatami
  scope :active, -> { where(status: [:confirmed, :attended]) }

  # --- VALIDATIONS (Business Logic) ---
  
  # 1. Capacity: Only validates if the booking is active and not an Admin who forces it
  validate :ensure_capacity, if: -> { active_status? && status_changed? && !admin_override? }
  
  # 2. Change Limit: Only validates if not an Admin
  validate :check_submission_limit, on: :update, unless: :admin_override?

  # --- REACTIVIDAD (Turbo Streams) ---
  # Run after saving (commit) to ensure integrity
  
  # A. Update the public counter of spots
  after_commit :broadcast_spots_update

  # B. Update the private button of the user (Book vs Cancel)
  after_commit :broadcast_user_button

  # --- BUSINESS LOGIC METHODS ---

  def active_status?
    confirmed? || attended?
  end

  def admin_override?
    changed_by&.admin? || changed_by&.instructor?
  end

  # THE MASTER METHOD: Handles all transitions
  def update_status!(new_status, actor)
    self.changed_by = actor
    
    # Indecision counter logic:
    # If it's the same user changing their status, we add to the counter.
    # If it's the admin, we don't penalize the user by adding to the counter.
    if actor == user && status != new_status
      self.submission_count += 1
    end

    self.status = new_status
    save!
  end

  # Wrapper method for the simple user button action (Toggle)
  def toggle_by_user!
    if active_status?
      update_status!(:cancelled_user, user)
    else
      update_status!(:confirmed, user)
    end
  end

  private

  def ensure_capacity
    # Validate against the spots_left method of the schedule
    if class_schedule.spots_left <= 0
      errors.add(:base, "La clase está llena.")
    end
  end

  def check_submission_limit
    # Submission limit policy: Maximum 3 attempts allowed
    if submission_count > 3
      errors.add(:base, "You have exceeded the allowed number of changes.")
    end
  end

  # --- BROADCASTS ---

  def broadcast_spots_update
    # Broadcast to: "schedule_1"
    # Update: <div id="spots_schedule_1">
    broadcast_replace_to "schedule_#{class_schedule.id}", 
                         target: "spots_schedule_#{class_schedule.id}", 
                         partial: "class_schedules/spots", 
                         locals: { schedule: class_schedule }
  end

  def broadcast_user_button
    # Broadcast to the private channel of the user: [user, "bookings"]
    # Update: <div id="action_button_schedule_1">
    broadcast_replace_to [user, "bookings"],
                         target: "action_button_schedule_#{class_schedule.id}",
                         partial: "class_schedules/action_button",
                         locals: { schedule: class_schedule, user: user }
  end
end