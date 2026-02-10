class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_plan
  belongs_to :membership_package

  enum :status, { active: 0, expired: 1, cancelled: 2 }, default: :active

  validates :start_date, presence: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes using Date.current for timezone safety
  scope :active, -> { where(status: :active).where("end_date >= ?", Date.current) }

  # Callbacks: before_validation allows setting data before db constraints check
  before_validation :calculate_end_date, on: :create
  before_validation :calculate_amount_paid, on: :create
  after_create :expire_conflicting_memberships

  def active?
    status == "active" && end_date >= Date.current
  end

  def expired?
    end_date < Date.current
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.current).to_i
  end

  def drop_in?
    membership_plan&.duration_months == 0
  end

  private

  def calculate_end_date
    return if end_date.present? # Allow manual override

    return unless start_date && membership_plan

    if drop_in?
      self.end_date = start_date
    else
      self.end_date = start_date + membership_plan.duration_months.months
    end
  end

  def calculate_amount_paid
    return if amount_paid.present? # Allow manual override

    return unless membership_plan && membership_package
    
    base_price = membership_plan.price
    modifier = membership_package.price_modifier || 0
    total = base_price + modifier
    
    # Apply 50% discount for second discipline
    if concurrent_membership?
      total = total * 0.5
    end
    
    self.amount_paid = total
  end

  def concurrent_membership?
    # Check if user has another active recurring membership
    user.memberships
        .active
        .where.not(id: id)
        .where(membership_plan_id: MembershipPlan.recurring.select(:id))
        .exists?
  end

  def expire_conflicting_memberships
    # Expire previous drop-ins only
    user.memberships
        .where.not(id: id)
        .active
        .joins(:membership_plan)
        .where(membership_plans: { duration_months: 0 })
        .update_all(status: :expired)
  end
end