class MembershipPricing < ApplicationRecord
  belongs_to :membership_package
  belongs_to :membership_plan

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
