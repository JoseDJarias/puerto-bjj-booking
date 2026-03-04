class MembershipPlan < ApplicationRecord
  has_many :memberships
  has_many :membership_pricings, dependent: :destroy

  validates :name, :duration_months, :price, presence: true
  validates :duration_months, numericality: { greater_than_or_equal_to: 0 } # Permitir 0 para drop-in

  scope :active, -> { where(active: true) }

  def display_name
    "#{name} (#{duration_months} #{'mes'.pluralize(duration_months)})"
  end
  
end
