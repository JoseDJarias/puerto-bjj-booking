class MembershipPlan < ApplicationRecord
  has_many :memberships

  validates :name, :duration_months, :price, presence: true
  validates :duration_months, numericality: { greater_than_or_equal_to: 0 } # Permitir 0 para drop-in
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :drop_in, -> { where(duration_months: 0) }
  scope :recurring, -> { where("duration_months > 0") }

  def display_name
    return "#{name} (1 día)" if duration_months == 0
    "#{name} (#{duration_months} #{'mes'.pluralize(duration_months)})"
  end

  def drop_in?
    duration_months == 0
  end
end
