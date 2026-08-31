require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:rashguard)
    sign_in_as(@user)
  end

  test "should redirect index if unauthenticated" do
    sign_out
    get products_path
    assert_redirected_to new_session_url
  end

  test "should get index with active products and avoid N+1 queries" do
    assert_queries(8) do
      get products_path
    end
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select "h1", I18n.t("products.index.title")
  end

  test "should get index with empty catalog (nullability)" do
    # Make all products inactive
    Product.update_all(active: false)
    
    get products_path
    assert_response :success
    assert_equal 0, assigns(:products).size
    # It should display the empty state
  end

  test "should get show for active product and avoid N+1 queries" do
    assert_queries(9) do
      get product_path(@product)
    end
    assert_response :success
    assert_not_nil assigns(:product)
    assert_select "h1", @product.name
  end
end
