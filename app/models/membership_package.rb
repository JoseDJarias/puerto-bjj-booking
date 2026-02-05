class MembershipPackage < ApplicationRecord
  has_many :memberships
  has_many :membership_package_class_types, dependent: :destroy
  has_many :class_types, through: :membership_package_class_types

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def includes_class_type?(class_type)
    class_types.include?(class_type)
  end

  def class_type_names
    class_types.pluck(:name).join(" + ")
  end
end
