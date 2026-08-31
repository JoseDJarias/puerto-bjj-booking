class Group < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :messages, dependent: :destroy

  validates :name, presence: true
end
