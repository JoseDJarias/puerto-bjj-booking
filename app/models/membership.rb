class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_plan
  belongs_to :membership_package

  enum :status, { active: 0, expired: 1, cancelled: 2 }, default: :active

  validates :start_date, presence: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # 'current': It means that the status is active and the date is valid.
  # We use the modern syntax for infinite ranges (Date.current..)
  scope :current, -> { active.where(end_date: Date.current..) }

  before_validation :calculate_end_date, on: :create
  before_validation :calculate_amount_paid, on: :create
  after_create :expire_conflicting_drop_ins

  def current?
    active? && end_date.present? && end_date >= Date.current
  end

  # Helper methods
  def days_remaining
    return 0 unless end_date
    remaining = (end_date - Date.current).to_i
    remaining.positive? ? remaining : 0
  end

  def drop_in?
    # Delegate the logic to the plan if possible, or check the duration is 0
    membership_plan&.drop_in?
  end

  private

  # === CALCULATIONS ===

  def calculate_end_date
    return if end_date.present? # Allow manual override

    # Guard clause: If there is no start date or plan, we cannot calculate
    return unless start_date && membership_plan

    if drop_in?
      self.end_date = start_date # Drop-in expires the same day
    else
      # .months is a method of ActiveSupport, very secure
      self.end_date = start_date + membership_plan.duration_months.months
    end
  end

  def calculate_amount_paid
    return if amount_paid.present?

    return unless membership_plan && membership_package
    
    base_price = membership_plan.price
    modifier = membership_package.price_modifier || 0
    total = base_price + modifier
    
    # Apply discount if applicable
    if concurrent_recurring_membership?
      total *= 0.5 # 50% discount
    end
    
    self.amount_paid = total
  end

  # === BUSINESS LOGIC ===

  def concurrent_recurring_membership?
    # Search if the user has another active and valid recurring membership
    user.memberships
        .current           # We use our new combined scope
        .where.not(id: id) # That is not this one (important in updates)
        .joins(:membership_plan)
        .where("membership_plans.duration_months > 0") # Only recurring plans
        .exists?
  end

  def expire_conflicting_drop_ins
    # If I buy a monthly membership, I expire my old active drop-ins
    # Only if the current one is not a drop-in
    return if drop_in?

    user.memberships
        .where.not(id: id)
        .active # Search by status DB
        .joins(:membership_plan)
        .where(membership_plans: { duration_months: 0 }) # They are drop-ins
        .update_all(status: :expired)
  end
end