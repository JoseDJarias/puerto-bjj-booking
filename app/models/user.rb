class User < ApplicationRecord
  include Authorizable
  include MembershipValidator
  
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :drop_in_tickets, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :identification, presence: true, uniqueness: true, on: :update # Opcional: obligatorio solo al completar perfil
  validates :nickname, uniqueness: true, allow_blank: true

  def display_name
    nickname.presence || first_name
  end
  
  def full_legal_name
    "#{first_name} #{last_name}"
  end
end
