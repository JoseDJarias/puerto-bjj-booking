class MembershipPackage < ApplicationRecord
  has_many :memberships
  has_many :membership_package_class_types, dependent: :destroy
  has_many :class_types, through: :membership_package_class_types
  has_many :membership_pricings, dependent: :destroy
  has_many :membership_plans, through: :membership_pricings
  
  accepts_nested_attributes_for :membership_pricings, allow_destroy: true

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def includes_class_type?(class_type)
    class_types.include?(class_type)
  end

  def class_type_names
    class_types.pluck(:name).join(" + ")
  end

  def price_for(plan)
    membership_pricings.find_by(membership_plan: plan)&.price
  end

  # ¿Este plan aplica a este paquete? (ej. paquetes drop-in solo con planes duration_months == 0)
  def valid_plan?(plan)
    return plan.duration_months == 0 if drop_in_package?
    true
  end

  # Precio mínimo entre los planes que aplican a este paquete (para la UI "desde X")
  def lowest_price(plans)
    valid = plans.select { |p| valid_plan?(p) }
    return nil if valid.empty?
    valid.filter_map { |p| price_for(p) }.min
  end

  private

  def drop_in_package?
    name = self.name.to_s.downcase
    name.include?("drop") || name.include?("dia") || name.include?("visita")
  end
end
