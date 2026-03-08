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

    MAX_SUBMISSION_LIMIT = 3
    
    # 1. Capacity: Only validates if the booking is active and not an Admin who forces it
    validate :ensure_capacity, if: -> { active_status? && status_changed? && !admin_override? }
    
    # 2. Change Limit: Only validates if not an Admin
    validate :check_submission_limit, on: :update, unless: :admin_override?

    # --- REACTIVIDAD (Turbo Streams) ---
    # Run after saving (commit) to ensure integrity
    
    after_commit :broadcast_realtime_updates_for_users
    # after_commit :broadcast_participants_update

    after_update :process_attendance_payment, if: -> { attended? && saved_change_to_status? }
    

    # --- BUSINESS LOGIC METHODS ---

    def active_status?
      confirmed? || attended?
    end

    def admin_override?
      changed_by&.admin? || changed_by&.instructor?
    end

    # THE MASTER METHOD: Handles all transitions
    # Handles the initial creation or toggle, with locks and validations.
    def handle_user_action!(actor)
      class_schedule.with_lock do
        if new_record?
          self.status = :confirmed
          self.changed_by = actor
          save
        else
          toggle_by_user!
        end
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
    
    def update_status!(new_status, actor)
      self.changed_by = actor
      
      # Indecision counter logic:
      # If it's the same user changing their status, we add to the counter.
      # If it's the admin, we don't penalize the user by adding to the counter.
      if status != new_status.to_s && actor == user && !actor.admin? && !actor.instructor? 
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

    def limit_reached?
      submission_count >= MAX_SUBMISSION_LIMIT
    end

    private

    def ensure_capacity
      # Validate against the spots_left method of the schedule
      if class_schedule.spots_left <= 0
        errors.add(:base, "La clase está llena.")
      end
    end

    def check_submission_limit
      return if status.to_s == 'cancelled_user'
      # Submission limit policy: Maximum 3 attempts allowed
      if submission_count > MAX_SUBMISSION_LIMIT && status_changed?
        errors.add(:base, I18n.t('bookings.messages.limit_reached'))
      end
    end

    def process_attendance_payment
      # 1. Is the sport covered by an active membership?
      # We look if the membership package includes the class type of this booking
      return if user.memberships.current.any? { |m| m.membership_package.includes_class_type?(class_schedule.class_type) }

      # 2. Has already activated a Drop-in today? 
      # If there is a ticket 'used_today', this class is free.
      return if user.drop_in_active_today?

      # 3. If there is no membership or active ticket today, we try to activate a new one
      ticket = user.available_ticket_for(class_schedule.class_type)

      if ticket
        ticket.activate!(self)
      else
        # 3. There is nothing: Here you could mark a debt or notify the admin
        # Rails.logger.warn "User #{user.id} attended without prior payment."
      end
    end

    # --- BROADCASTS ---
    def broadcast_realtime_updates_for_users
      # 1. Update Spots (Public)
      broadcast_spots_update

      # 2. Update User Button (Private)
      broadcast_user_button if user.present?

      # 3. Update Participants List (Public)
      broadcast_participants_list_update
    end

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

    def broadcast_participants_list_update
      broadcast_replace_to "schedule_#{class_schedule_id}",
                            target: "frame_participants_#{class_schedule_id}",
                            partial: "class_schedules/participants_list",
                            locals: { schedule: class_schedule }
    end
    # --- BROADCASTS --- END ---
  end