module Authorizable
  extend ActiveSupport::Concern

  # Roles (hierarchical)
  ROLES = {
    member: 0,
    instructor: 1,
    admin: 2
  }.freeze

  included do
    enum :role, ROLES, default: :member
    enum :status, { active: 0, inactive: 1, suspended: 2 }, default: :active
  end

  # === User status and permissions ===
  
  def approved? = admin? || instructor? || approved_at.present?
  def eligible? = active? && approved?
  def pending_approval? = !approved? && member?

  # === ADMINISTRATIVE PERMISSIONS ===
  
  def manage_memberships? = admin?
  def manage_users? = admin?
  def manage_classes? = admin?
  def check_in_students? = instructor? || admin?
  def view_reports? = instructor? || admin?
  def manage_plans_and_packages? = admin?

  # === HELPERS DE ROLES ===
  
  def admin? = role == "admin"
  def instructor? = role == "instructor" || admin?
  def member? = role == "member"
end
