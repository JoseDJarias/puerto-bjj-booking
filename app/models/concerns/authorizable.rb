module Authorizable
  extend ActiveSupport::Concern

  # Roles (jerárquicos)
  ROLES = {
    member: 0,
    instructor: 1,
    admin: 2
  }.freeze

  included do
    enum :role, ROLES, default: :member
    enum :status, { active: 0, inactive: 1, suspended: 2 }, default: :active
  end

  # === PERMISOS DE RESERVA ===
  
  def can_book_classes?
    active? && approved? && valid_membership?
  end

  def valid_membership?
    current_memberships.any?(&:active?)
  end

  # === PERMISOS ADMINISTRATIVOS ===
  
  def can_manage_classes?
    admin?
  end

  def can_manage_users?
    admin?
  end

  def can_manage_memberships?
    admin?
  end

  def can_check_in_students?
    instructor? || admin?
  end

  def can_view_reports?
    instructor? || admin?
  end

  def can_manage_plans_and_packages?
    admin?
  end

  # === HELPERS DE ROLES ===
  
  def instructor?
    role == "instructor" || admin?
  end

  def admin?
    role == "admin"
  end

  def member?
    role == "member"
  end

  # === APROBACIÓN (registro pendiente de admin) ===
  # Admins e instructores se consideran aprobados por defecto.
  
  def approved?
    admin? || instructor? || approved_at.present?
  end

  def pending_approval?
    !approved? && member?
  end

  # === MEMBRESÍA ===
  
  def current_memberships
    # Retorna TODAS las membresías activas (puede tener múltiples disciplinas)
    memberships.active.order(end_date: :desc)
  end

  def membership_expires_soon?(days = 7)
    return false unless current_memberships.any?
    current_memberships.any? { |m| m.days_remaining <= days && m.days_remaining > 0 }
  end

  def all_accessible_class_types
    # Retorna todos los tipos de clase a los que tiene acceso
    current_memberships.flat_map { |m| m.membership_package.class_types }.uniq
  end
end
