class User < ApplicationRecord
  include Authorizable
  include MembershipValidator

  attr_accessor :admin_editing_password
  
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :drop_in_tickets, dependent: :destroy
  has_many :bookings, dependent: :destroy

 #pending how to destroy a instructor user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :nickname, uniqueness: { allow_blank: true }
  validates :password, length: { minimum: 8 }, allow_nil:true
  
  # Identification validation
  before_validation :normalize_identification
  validates :identification, presence: true, unless: :admin_editing_password
  validates :identification, uniqueness: true, if: -> { identification.present? && !admin_editing_password }
  validate :flexible_identification_check, if: -> { identification.present? }

  #Admin scope for accounts management
  scope :pending, -> { where(approved_at: nil) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :active_status, -> { where(status: :active) }
  scope :inactive_status, -> { where(status: :inactive) }

  scope :by_membership_package, ->(package_id) {
    joins(:memberships).merge(Membership.by_package(package_id))
    .merge(Membership.current)
    .distinct
  }
  #Search Filtering
  scope :search_by_query, ->(query) {
    return all if query.blank?
    q = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
    where("first_name LIKE :q OR last_name LIKE :q OR email_address LIKE :q OR identification LIKE :q OR phone_number LIKE :q", q: q)
  }

  def display_name
    nickname.presence || first_name
  end
  
  def full_legal_name
    "#{first_name} #{last_name}"
  end

  UserStats = Struct.new(:total, :pending, :approved, :inactive)
  def self.stats(base_scope = User.all)
    counts = base_scope.select(
      "COUNT(*) as total_rows",
      "COUNT(CASE WHEN approved_at IS NULL THEN 1 END) as pending_rows",
      "COUNT(CASE WHEN approved_at IS NOT NULL THEN 1 END) as approved_rows",
      "COUNT(CASE WHEN status IN (1, 2) THEN 1 END) as inactive_rows"
    ).take

    UserStats.new(
      counts["total_rows"].to_i,
      counts["pending_rows"].to_i,
      counts["approved_rows"].to_i,
      counts["inactive_rows"].to_i
    )
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
  
    # National (Only numbers)
    if identification =~ /\A\d+\z/
      # In CR the identification is sacred: 9 digits. 
      # If someone puts 7, 8 or 10 numbers, it's a mistake of the finger the 99% of the times.
      if identification.length == 9
        return
      else
        errors.add(:identification, "debe tener exactamente 9 dígitos (Cédula CR). Si es un pasaporte numérico, verifíquelo con el Admin.")
      end
      return
    end
  
    # Foreigner (Alphanumeric)
    # A real passport almost always has a letter or is a format that we have already validated
    if identification =~ /\A[A-Z0-9]{6,15}\z/
      return
    else
      errors.add(:identification, "formato de pasaporte inválido (debe tener entre 6 y 15 caracteres)")
    end
  end
end
