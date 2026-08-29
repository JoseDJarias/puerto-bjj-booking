require "test_helper"

class ProductOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:rashguard)
    sign_in_as(@user)
  end

  test "should get new order form" do
    get new_product_product_order_path(@product)
    assert_response :success
  end

  test "should create product order and send admin notification" do
    assert_difference -> { @user.product_orders.count }, 1 do
      assert_enqueued_emails 1 do
        post product_product_orders_path(@product), params: {
          product_order: {
            user_notes: "Talla L, Color Negro",
            terms_accepted: "1",
            payment_receipt: fixture_file_upload("test/fixtures/files/receipt.png", "image/png")
          }
        }
      end
    end

    order = @user.product_orders.last
    assert_redirected_to my_order_path(order)
    follow_redirect!
    assert_response :success
  end

  test "should get my orders index" do
    get my_orders_path
    assert_response :success
  end
end
