class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :membership_plan
  belongs_to :membership_package

  enum :status, { active: 0, expired: 1, cancelled: 2 }, default: :active

  validates :start_date, presence: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :current, -> { active.where(end_date: Time.zone.today..) }
  scope :expired_listing, -> { expired.or(where(end_date: ...Time.zone.today)) }
  scope :past, -> { where(end_date: ...Time.zone.today).or(where(status: [:expired, :cancelled])) }
  
  #Package Filtering, use it with merge in other scopes
  scope :by_package, ->(package_id) { where(membership_package_id: package_id) }

  before_validation :calculate_end_date, on: :create
  before_validation :calculate_amount_paid, on: :create

  def current?
    active? && end_date.present? && end_date >= Time.zone.today
  end
  # Helper methods
  def days_remaining
    return 0 unless end_date
    [ (end_date - Time.zone.today).to_i, 0 ].max
  end

  def preview_totals
    calculate_end_date
    calculate_amount_paid
  end

  def self.stats
    counts = group(:status).count
    
    Struct.new(:active, :expired, :total).new(
      counts["active"] || 0,
      counts["expired"] || 0,
      counts.values.sum
    )
  end

  private

  # === CALCULATIONS ===
  def calculate_end_date
    return if end_date.present?
    return unless start_date && membership_plan

    self.end_date = start_date + membership_plan.duration_months.months
  end

  def calculate_amount_paid
    return if amount_paid.present?

    return unless membership_plan_id && membership_package_id
  
    pricing = MembershipPricing.find_by(
      membership_package_id: membership_package_id, 
      membership_plan_id: membership_plan_id
    )
    
    self.amount_paid = pricing&.price || 0
  end 
end