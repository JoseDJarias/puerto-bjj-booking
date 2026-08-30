require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @product = products(:rashguard)
  end

  test "should redirect index if unauthenticated" do
    get admin_products_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    
    assert_queries_count(2..6) do
      get admin_products_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    
    assert_queries_count(2..8) do
      get admin_products_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:products)
  end

  test "should get new" do
    sign_in_as(@admin)
    
    assert_queries_count(1..6) do
      get new_admin_product_path
    end
    assert_response :success
    assert_kind_of Product, assigns(:product)
  end

  test "should create product" do
    sign_in_as(@admin)
    
    assert_difference -> { Product.count }, 1 do
      assert_queries_count(2..10) do
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
    end

    new_product = Product.last
    assert_redirected_to admin_product_path(new_product)
  end

  test "should update product and attach new images" do
    sign_in_as(@admin)
    
    assert_difference -> { @product.images.count }, 1 do
      assert_queries_count(2..12) do
        patch admin_product_path(@product), params: {
          product: {
            name: "Rashguard Puerto BJJ Pro Actualizado",
            price: 26000,
            images: [
              fixture_file_upload("test/fixtures/files/receipt.png", "image/png")
            ]
          }
        }
      end
    end

    assert_redirected_to admin_product_path(@product)
    @product.reload
    assert_equal "Rashguard Puerto BJJ Pro Actualizado", @product.name
    assert_equal 26000.0, @product.price
  end

  test "should destroy product" do
    sign_in_as(@admin)
    
    assert_difference -> { Product.count }, -1 do
      assert_queries_count(2..10) do
        delete admin_product_path(@product)
      end
    end

    assert_redirected_to admin_products_path
  end

  test "should destroy individual product image" do
    sign_in_as(@admin)
    
    @product.images.attach(
      io: StringIO.new("fake image content"),
      filename: "product.png",
      content_type: "image/png"
    )
    image = @product.images.last

    assert_difference -> { @product.images.count }, -1 do
      assert_queries_count(2..10) do
        delete destroy_image_admin_product_path(@product, image_id: image.id)
      end
    end

    assert_redirected_to edit_admin_product_path(@product)
  end
end
