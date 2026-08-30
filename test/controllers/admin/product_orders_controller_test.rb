require "test_helper"

class Admin::ProductOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @order = product_orders(:one) rescue nil
    
    if @order.nil?
      product = products(:rashguard)
      @order = ProductOrder.new(user: @student, product: product, terms_accepted: "1")
      @order.payment_receipt.attach(
        io: StringIO.new("fake image content"),
        filename: "receipt.png",
        content_type: "image/png"
      )
      @order.save!
    end
  end

  test "should redirect index if unauthenticated" do
    get admin_product_orders_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries_count(2..6) do
      get admin_product_orders_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get admin_product_orders_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:orders)
  end

  test "should get show" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get admin_product_order_path(@order)
    end
    assert_response :success
    assert_kind_of ProductOrder, assigns(:order)
  end

  test "should update order admin notes" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      patch admin_product_order_path(@order), params: {
        product_order: { admin_notes: "Pagado por sinpe" }
      }
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "Pagado por sinpe", @order.admin_notes
  end

  test "should confirm payment" do
    sign_in_as(@admin)
    assert_enqueued_emails 1 do
      assert_queries_count(2..15) do
        patch confirm_payment_admin_product_order_path(@order)
      end
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "payment_confirmed", @order.status
  end

  test "should mark as ordered from supplier" do
    sign_in_as(@admin)
    @order.payment_confirmed!
    
    assert_enqueued_emails 1 do
      assert_queries_count(2..15) do
        patch mark_as_ordered_admin_product_order_path(@order)
      end
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "ordered_from_supplier", @order.status
  end

  test "should mark as ready" do
    sign_in_as(@admin)
    @order.ordered_from_supplier!
    
    assert_enqueued_emails 1 do
      assert_queries_count(2..15) do
        patch mark_as_ready_admin_product_order_path(@order)
      end
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "ready_for_pickup", @order.status
  end

  test "should mark as delivered" do
    sign_in_as(@admin)
    @order.ready_for_pickup!
    
    assert_queries_count(2..10) do
      patch mark_as_delivered_admin_product_order_path(@order)
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "delivered", @order.status
  end

  test "should cancel order" do
    sign_in_as(@admin)
    
    assert_queries_count(2..10) do
      patch cancel_order_admin_product_order_path(@order)
    end
    assert_redirected_to admin_product_order_path(@order)
    @order.reload
    assert_equal "cancelled", @order.status
  end
end
