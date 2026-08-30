require "test_helper"

class ProductOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:rashguard)
    sign_in_as(@user)
  end

  test "should redirect new if unauthenticated" do
    sign_out
    get new_product_product_order_path(@product)
    assert_redirected_to new_session_url
  end

  test "should get new order form" do
    assert_queries_count(2..8) do
      get new_product_product_order_path(@product)
    end
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:product_order)
  end

  test "should create product order and send admin notification" do
    assert_difference -> { @user.product_orders.count }, 1 do
      assert_enqueued_emails 1 do
        assert_queries_count(4..15) do
          post product_product_orders_path(@product), params: {
            product_order: {
              user_notes: "Talla L, Color Negro",
              terms_accepted: "1",
              payment_receipt: fixture_file_upload("test/fixtures/files/receipt.png", "image/png")
            }
          }
        end
      end
    end

    order = @user.product_orders.last
    assert_redirected_to my_order_path(order)
    follow_redirect!
    assert_response :success
  end
  
  test "should fail to create without terms accepted" do
    assert_no_difference -> { @user.product_orders.count } do
      assert_queries_count(2..8) do
        post product_product_orders_path(@product), params: {
          product_order: {
            user_notes: "Talla L, Color Negro",
            terms_accepted: "0",
            payment_receipt: fixture_file_upload("test/fixtures/files/receipt.png", "image/png")
          }
        }
      end
    end
    
    # Renders new with unprocessable_entity
    assert_response :unprocessable_entity
    assert_not_empty assigns(:product_order).errors
  end

  test "should get my orders index" do
    assert_queries_count(2..10) do
      get my_orders_path
    end
    assert_response :success
    assert_not_nil assigns(:orders)
  end
  
  test "should get my orders with empty list" do
    # Clear orders
    @user.product_orders.destroy_all
    
    assert_queries_count(2..8) do
      get my_orders_path
    end
    assert_response :success
    assert_equal 0, assigns(:orders).size
  end
end
