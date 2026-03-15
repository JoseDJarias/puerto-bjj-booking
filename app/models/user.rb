class User < ApplicationRecord
  include Authorizable
  include MembershipValidator
  
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :drop_in_tickets, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :identification, presence: true, on: :create
  validates :nickname, uniqueness: { allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil:true

  # Identification validation
  before_validation :normalize_identification
  validates :identification, presence: true, uniqueness: true
  validate :flexible_identification_check

  def display_name
    nickname.presence || first_name
  end
  
  def full_legal_name
    "#{first_name} #{last_name}"
  end

  private

  def normalize_identification
    return if identification.blank?
    if will_save_change_to_identification?
      self.identification = identification.to_s.gsub(/[-\s]/, "").upcase
    end
  end

  def flexible_identification_check
    return if identification.blank?

    # If it's only numbers and measures 9, it's a CR identification
    if identification =~ /\A\d+\z/ && identification.length == 9
      return
    # If it's alphanumeric (letters/numbers) between 6 and 15 characters, it's a Passport/International identification
    elsif identification =~ /\A[A-Z0-9]{6,15}\z/
      return
    else
      errors.add(:identification, "debe ser una cédula de 9 dígitos o un pasaporte válido (6-15 caracteres)")
    end
  end  
end
