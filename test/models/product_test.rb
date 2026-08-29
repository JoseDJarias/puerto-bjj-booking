require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "validates presence of name" do
    product = Product.new(price: 10000, deposit_percentage: 50)
    assert_not product.valid?
    assert_includes product.errors[:name], I18n.t("errors.messages.blank")
  end

  test "validates price numericality" do
    product = Product.new(name: "Test", price: -100, deposit_percentage: 50)
    assert_not product.valid?
    assert_includes product.errors[:price], "debe ser mayor que o igual a 0"
  end

  test "calculates correct deposit amount" do
    product = Product.new(name: "Rashguard", price: 20000, deposit_percentage: 50)
    assert_equal 10000.0, product.deposit_amount

    product.deposit_percentage = 40
    assert_equal 8000.0, product.deposit_amount
  end

  test "active scope returns only active products" do
    active_products = Product.active
    assert_includes active_products, products(:rashguard)
    assert_not_includes active_products, products(:kimono)
  end
end
