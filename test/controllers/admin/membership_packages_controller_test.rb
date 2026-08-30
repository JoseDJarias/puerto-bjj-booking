require "test_helper"

class Admin::MembershipPackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @package = membership_packages(:unlimited) rescue nil
    
    if @package.nil?
      @package = MembershipPackage.create!(name: "Unlimited", price_modifier: 0, active: true)
    end
  end

  test "should redirect index if unauthenticated" do
    get admin_membership_packages_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries_count(2..6) do
      get admin_membership_packages_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get admin_membership_packages_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:packages)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries_count(1..6) do
      get new_admin_membership_package_path
    end
    assert_response :success
    assert_kind_of MembershipPackage, assigns(:membership_package)
  end

  test "should create membership package" do
    sign_in_as(@admin)
    
    assert_difference -> { MembershipPackage.count }, 1 do
      assert_queries_count(2..10) do
        post admin_membership_packages_path, params: {
          membership_package: {
            name: "Basic",
            description: "2x per week",
            price_modifier: -10000,
            active: true
          }
        }
      end
    end
    
    assert_redirected_to admin_membership_packages_path
  end

  test "should get edit" do
    sign_in_as(@admin)
    assert_queries_count(2..8) do
      get edit_admin_membership_package_path(@package)
    end
    assert_response :success
    assert_kind_of MembershipPackage, assigns(:membership_package)
  end

  test "should update membership package" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      patch admin_membership_package_path(@package), params: {
        membership_package: { name: "Unlimited Plus" }
      }
    end
    assert_redirected_to admin_membership_packages_path
    @package.reload
    assert_equal "Unlimited Plus", @package.name
  end
end
