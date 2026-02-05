class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_plan
  belongs_to :membership_package

  enum :status, { active: 0, expired: 1, cancelled: 2 }, default: :active

  validates :start_date, presence: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(status: :active).where("end_date >= ?", Date.today) }

  before_create :calculate_end_date
  before_create :calculate_amount_paid
  after_create :expire_conflicting_memberships

  def active?
    status == "active" && end_date >= Date.today
  end

  def expired?
    end_date < Date.today
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.today).to_i
  end

  def expires_soon?(days = 7)
    days_remaining <= days && days_remaining > 0
  end

  def drop_in?
    membership_plan.duration_months == 0
  end

  def recurring?
    !drop_in?
  end

  private

  def calculate_end_date
    if membership_plan.duration_months == 0
      # Drop-in: solo válido por el día
      self.end_date = start_date
    else
      # Planes regulares
      self.end_date = start_date + membership_plan.duration_months.months
    end
  end

  def calculate_amount_paid
    return if amount_paid.present?
    
    base_price = membership_plan.price
    modifier = membership_package.price_modifier || 0
    total = base_price + modifier
    
    # Aplicar descuento del 50% si es segunda disciplina
    if concurrent_membership?
      total = total * 0.5
    end
    
    self.amount_paid = total
  end

  def concurrent_membership?
    # Verificar si ya tiene otra membresía activa recurrente
    user.memberships
        .where(status: :active)
        .where("end_date >= ?", Date.today)
        .where("id != ?", id || 0)
        .where("memberships.membership_plan_id IN (?)", MembershipPlan.recurring.pluck(:id))
        .exists?
  end

  def expire_conflicting_memberships
    # Solo expirar membresías drop-in anteriores
    # Las membresías recurrentes pueden coexistir (para combos de disciplinas)
    user.memberships
        .where.not(id: id)
        .where(status: :active)
        .joins(:membership_plan)
        .where(membership_plans: { duration_months: 0 })
        .update_all(status: :expired)
  end
end
