require "test_helper"

class Admin::ClassTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @class_type = class_types(:bjj) rescue nil
    
    if @class_type.nil?
      @class_type = ClassType.create!(name: "BJJ", description: "Brazilian Jiu Jitsu", active: true)
    end
  end

  test "should redirect index if unauthenticated" do
    get admin_class_types_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries(2) do
      get admin_class_types_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries(3) do
      get admin_class_types_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:class_types)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries(2) do
      get new_admin_class_type_path
    end
    assert_response :success
    assert_kind_of ClassType, assigns(:class_type)
  end

  test "should create class type" do
    sign_in_as(@admin)
    
    assert_difference -> { ClassType.count }, 1 do
      assert_queries(4) do
        post admin_class_types_path, params: {
          class_type: {
            name: "Muay Thai",
            description: "Thai Boxing",
            active: true
          }
        }
      end
    end
    
    assert_redirected_to admin_class_types_path
  end

  test "should get edit" do
    sign_in_as(@admin)
    assert_queries(3) do
      get edit_admin_class_type_path(@class_type)
    end
    assert_response :success
    assert_kind_of ClassType, assigns(:class_type)
  end

  test "should update class type" do
    sign_in_as(@admin)
    assert_queries(5) do
      patch admin_class_type_path(@class_type), params: {
        class_type: { name: "BJJ Advanced" }
      }
    end
    assert_redirected_to admin_class_types_path
    @class_type.reload
    assert_equal "BJJ Advanced", @class_type.name
  end
end
