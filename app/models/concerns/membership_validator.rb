module MembershipValidator
  extend ActiveSupport::Concern

  # Responds: "Do we show active_member or pricing_options?"
  def has_booking_access?
    return true if admin?
    return false unless eligible?  # Authorizable

    current_memberships.exists? ||
      drop_in_active_today? ||
      unused_tickets?
  end

  # Responds: "Does the user have access to this class?"
 def authorized_for?(class_type)
  return true if admin?

    return false unless eligible? # De Authorizable

    # 1. ¿Tiene membresía activa para este deporte?
    return true if covered_by_membership?(class_type)
    
    # 2. ¿Ya activó un Drop-in hoy? (Cubre todas las clases del día)
    return true if drop_in_active_today?

    # 3. ¿Tiene tickets sin usar en la billetera?
    return true if unused_tickets?

    false
  end

  def covered_by_membership?(class_type)
    current_memberships.any? { |m| m.membership_package.includes_class_type?(class_type) }
  end

  def active_on?(package_name)
    current_memberships.joins(:membership_package)
                       .where("LOWER(membership_packages.name) LIKE ?", "%#{package_name.downcase}%")
                       .exists?
  end

  def drop_in_active_today?
    drop_in_tickets.used.where(used_at: Time.current.all_day).exists?
  end

  def unused_tickets?
    drop_in_tickets.unused.exists?
  end

  # Universal drop-ins: one unused ticket = access to any class. Package param kept for API compatibility.
  def ticket_available_for?(_class_type = nil)
    drop_in_tickets.unused.exists?
  end

  # Universal drop-ins: returns first unused ticket. Package param kept for API compatibility.
  def available_ticket_for(_package = nil)
    drop_in_tickets.unused.first
  end

  def needs_membership_renewal?
    !covered_by_membership?(class_type) || membership_expires_soon?
  end

  # Class types the user can book: from memberships, or all if drop-in active today / has unused tickets.
  def bookable_class_types
    return ClassType.all if admin?
    return ClassType.all if drop_in_active_today? || unused_tickets?
    all_accessible_class_types
  end

  private

  def current_memberships
    memberships.current.order(end_date: :desc)
  end

  def membership_expires_soon?(days = 7)
    return false unless current_memberships.any?
    current_memberships.any? { |m| m.days_remaining <= days && m.days_remaining > 0 }
  end

  def all_accessible_class_types
    # Return all class types that the user has access to
    current_memberships.flat_map { |m| m.membership_package.class_types }.uniq
  end

end
