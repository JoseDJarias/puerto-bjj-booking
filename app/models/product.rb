class Product < ApplicationRecord
  has_many_attached :images
  has_many :product_orders, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :deposit_percentage, presence: true, numericality: { only_integer: true, in: 1..100 }

  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Calculates the required deposit amount for the product
  def deposit_amount
    ((price * deposit_percentage) / 100.0).round(2)
  end

  # Returns primary image or first attached image
  def main_image
    images.first if images.attached?
  end
end
