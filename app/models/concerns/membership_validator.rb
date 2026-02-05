module MembershipValidator
  extend ActiveSupport::Concern

  # === VALIDACIÓN DE ACCESO A CLASES ===
  
  def can_book?(class_type)
    return false unless can_book_classes?
    return false unless membership_includes_class_type?(class_type)
    true
  end

  def membership_includes_class_type?(class_type)
    return false unless current_memberships.any?
    
    # Verificar si ALGUNA de sus membresías incluye el class_type
    current_memberships.any? do |membership|
      membership.membership_package.class_types.include?(class_type)
    end
  end

  def days_remaining
    return 0 unless current_memberships.any?
    # Retornar el máximo días restantes de todas las membresías
    current_memberships.map(&:days_remaining).max
  end

  def membership_summary
    return "No active membership" unless current_memberships.any?
    
    memberships_info = current_memberships.map do |m|
      {
        plan: m.membership_plan.name,
        package: m.membership_package.name,
        days_remaining: m.days_remaining,
        expires_on: m.end_date,
        class_types: m.membership_package.class_types.pluck(:name),
        amount_paid: m.amount_paid
      }
    end
    
    {
      total_memberships: current_memberships.count,
      memberships: memberships_info,
      all_class_types: all_accessible_class_types.pluck(:name),
      earliest_expiration: current_memberships.map(&:end_date).min
    }
  end

  def needs_membership_renewal?
    !valid_membership? || membership_expires_soon?
  end
end
