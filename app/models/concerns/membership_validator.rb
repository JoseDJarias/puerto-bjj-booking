module MembershipValidator
  extend ActiveSupport::Concern

  def has_booking_access?
    return true if admin?
    return false unless eligible?

    any_active_membership? || any_active_drop_in? || unused_tickets?
  end

  # Responds: "Does the user have access to this class?"
  def authorized_for?(class_type)
    return true if admin?

    return false unless eligible? # From Authorizable concern

    covered_by_membership?(class_type) || any_active_drop_in? || unused_tickets?
  end

  def covered_by_membership?(class_type)
    current_memberships.any? { |m| m.membership_package.includes_class_type?(class_type) }
  end

  def needs_membership_renewal?
    !covered_by_membership?(class_type) || membership_expires_soon?
  end

  # Class types the user can book: from memberships, or all if drop-in active today / has unused tickets.
  def bookable_class_types
    all_accessible_class_types
  end

  # Drop in Tickets - Move this to another part of the code!
  def drop_in_active_today?
    any_active_drop_in?
  end

  def unused_tickets_count
    drop_in_tickets.unused.count
  end

  def unused_tickets?
    drop_in_tickets.unused.exists?
  end

  # Universal drop-ins: returns first unused ticket.
  def available_ticket
    drop_in_tickets.unused.first
  end
  # Drop in Tickets - Move this to another part of the code!

  private

  def any_active_membership?
    memberships.active.where(end_date: Time.zone.today..).exists?
  end

  def any_active_drop_in?
    drop_in_tickets.used.where(used_at: Time.zone.now.all_day).exists?
  end

  def current_memberships
    memberships.active.where(end_date: Time.zone.today..).order(end_date: :desc)
  end

  def membership_expires_soon?(days = 7)
    return false unless current_memberships.any?
    current_memberships.any? { |m| m.days_remaining <= days && m.days_remaining > 0 }
  end

  def all_accessible_class_types
    current_memberships.flat_map { |m| m.membership_package.class_types }.uniq
  end
end
