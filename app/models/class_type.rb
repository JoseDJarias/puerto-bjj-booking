class ClassType < ApplicationRecord
  has_many :membership_package_class_types, dependent: :destroy
  has_many :membership_packages, through: :membership_package_class_types

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
