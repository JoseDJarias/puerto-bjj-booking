require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @product = products(:rashguard)
    sign_in_as(@admin)
  end

  test "should get index" do
    get admin_products_path
    assert_response :success
    assert_select "h1", I18n.t("admin.products.index.title")
  end

  test "should get new" do
    get new_admin_product_path
    assert_response :success
  end

  test "should create product" do
    assert_difference -> { Product.count }, 1 do
      post admin_products_path, params: {
        product: {
          name: "Nuevo Rashguard V2",
          description: "Edición limitada",
          price: 28000,
          deposit_percentage: 50,
          active: true
        }
      }
    end

    assert_redirected_to admin_products_path
  end

  test "should update product" do
    patch admin_product_path(@product), params: {
      product: {
        name: "Rashguard Puerto BJJ Pro Actualizado",
        price: 26000
      }
    }

    assert_redirected_to admin_products_path
    @product.reload
    assert_equal "Rashguard Puerto BJJ Pro Actualizado", @product.name
    assert_equal 26000.0, @product.price
  end

  test "should destroy product" do
    assert_difference -> { Product.count }, -1 do
      delete admin_product_path(@product)
    end

    assert_redirected_to admin_products_path
  end

  test "should destroy individual product image" do
    @product.images.attach(
      io: StringIO.new("fake image content"),
      filename: "product.png",
      content_type: "image/png"
    )
    image = @product.images.last

    assert_difference -> { @product.images.count }, -1 do
      delete destroy_image_admin_product_path(@product, image_id: image.id)
    end

    assert_redirected_to edit_admin_product_path(@product)
  end
end
