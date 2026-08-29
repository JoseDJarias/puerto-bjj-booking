require "test_helper"

class Admin::ProductOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:one)
    @product = products(:rashguard)
    @order = @user.product_orders.create!(
      product: @product,
      terms_accepted: true,
      payment_receipt: {
        io: StringIO.new("fake receipt content"),
        filename: "receipt.png",
        content_type: "image/png"
      }
    )
    sign_in_as(@admin)
  end

  test "should get index" do
    get admin_product_orders_path
    assert_response :success
  end

  test "should get show" do
    get admin_product_order_path(@order)
    assert_response :success
  end

  test "confirm_payment transitions order and sends email" do
    assert_enqueued_emails 1 do
      patch confirm_payment_admin_product_order_path(@order)
    end

    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_predicate @order, :payment_confirmed?
  end

  test "mark_as_ordered transitions order and sends email" do
    @order.payment_confirmed!

    assert_enqueued_emails 1 do
      patch mark_as_ordered_admin_product_order_path(@order)
    end

    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_predicate @order, :ordered_from_supplier?
  end

  test "mark_as_ready transitions order and sends email" do
    @order.ordered_from_supplier!

    assert_enqueued_emails 1 do
      patch mark_as_ready_admin_product_order_path(@order)
    end

    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_predicate @order, :ready_for_pickup?
  end

  test "mark_as_delivered transitions order" do
    @order.ready_for_pickup!

    patch mark_as_delivered_admin_product_order_path(@order)

    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_predicate @order, :delivered?
  end

  test "cancel_order transitions order" do
    patch cancel_order_admin_product_order_path(@order)

    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_predicate @order, :cancelled?
  end
end
