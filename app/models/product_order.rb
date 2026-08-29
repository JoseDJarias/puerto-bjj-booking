class ProductOrder < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_one_attached :payment_receipt

  enum :status, {
    pending_verification: 0,
    payment_confirmed: 1,
    ordered_from_supplier: 2,
    ready_for_pickup: 3,
    delivered: 4,
    cancelled: 5
  }, default: :pending_verification

  validates :product_name, presence: true
  validates :product_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :deposit_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :terms_accepted, acceptance: true, on: :create
  validate :must_have_payment_receipt, on: :create

  before_validation :snapshot_product_details, on: :create
  before_create :set_terms_accepted_timestamp

  scope :recent, -> { order(created_at: :desc) }

  private

  # Snapshots the current product name, price, and calculated deposit
  def snapshot_product_details
    return unless product

    self.product_name ||= product.name
    self.product_price ||= product.price
    self.deposit_amount ||= product.deposit_amount
  end

  # Sets the timestamp when terms were accepted
  def set_terms_accepted_timestamp
    self.terms_accepted_at = Time.zone.now if terms_accepted
  end

  # Validates that a payment receipt attachment was provided
  def must_have_payment_receipt
    unless payment_receipt.attached?
      errors.add(:payment_receipt, :blank)
    end
  end
end
