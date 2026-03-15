class User < ApplicationRecord
  include Authorizable
  include MembershipValidator
  
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :drop_in_tickets, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :identification, presence: true, on: :create
  validates :identification,
            uniqueness: { allow_blank: true },
            format: { with: /\A[0-9]+\z/, message: :only_numbers, allow_blank: true }
  validates :nickname, uniqueness: { allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil:true

  def display_name
    nickname.presence || first_name
  end
  
  def full_legal_name
    "#{first_name} #{last_name}"
  end
end
