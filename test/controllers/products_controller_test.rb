require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:rashguard)
    sign_in_as(@user)
  end

  test "should get index with active products" do
    get products_path
    assert_response :success
    assert_select "h1", I18n.t("products.index.title")
  end

  test "should get show for active product" do
    get product_path(@product)
    assert_response :success
    assert_select "h1", @product.name
  end
end
