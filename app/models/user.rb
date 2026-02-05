class User < ApplicationRecord
  include Authorizable
  include MembershipValidator
  
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
