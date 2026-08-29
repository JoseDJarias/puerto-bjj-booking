require "test_helper"

class ProductOrderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:rashguard)
  end

  test "requires payment receipt on creation" do
    order = @user.product_orders.build(
      product: @product,
      terms_accepted: true
    )

    assert_not order.valid?
    assert_includes order.errors[:payment_receipt], I18n.t("errors.messages.blank")
  end

  test "requires terms acceptance on creation" do
    order = @user.product_orders.build(
      product: @product,
      terms_accepted: false
    )
    order.payment_receipt.attach(
      io: StringIO.new("fake receipt content"),
      filename: "receipt.png",
      content_type: "image/png"
    )

    assert_not order.valid?
    assert_includes order.errors[:terms_accepted], I18n.t("errors.messages.accepted")
  end

  test "snapshots product details on creation and sets default status" do
    order = @user.product_orders.build(
      product: @product,
      terms_accepted: true
    )
    order.payment_receipt.attach(
      io: StringIO.new("fake receipt content"),
      filename: "receipt.png",
      content_type: "image/png"
    )

    assert order.save
    assert_equal @product.name, order.product_name
    assert_equal @product.price, order.product_price
    assert_equal @product.deposit_amount, order.deposit_amount
    assert_predicate order, :pending_verification?
    assert_not_nil order.terms_accepted_at
  end

  test "transitions through status lifecycle" do
    order = @user.product_orders.create!(
      product: @product,
      terms_accepted: true,
      payment_receipt: {
        io: StringIO.new("fake receipt content"),
        filename: "receipt.png",
        content_type: "image/png"
      }
    )

    assert order.payment_confirmed!
    assert_predicate order, :payment_confirmed?

    assert order.ordered_from_supplier!
    assert_predicate order, :ordered_from_supplier?

    assert order.ready_for_pickup!
    assert_predicate order, :ready_for_pickup?

    assert order.delivered!
    assert_predicate order, :delivered?
  end
end
