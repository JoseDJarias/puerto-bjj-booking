class MembershipPackageClassType < ApplicationRecord
  belongs_to :membership_package
  belongs_to :class_type

  validates :class_type_id, uniqueness: { scope: :membership_package_id }
end
