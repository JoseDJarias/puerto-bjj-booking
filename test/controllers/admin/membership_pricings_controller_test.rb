require "test_helper"

class Admin::MembershipPricingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    
    @package = membership_packages(:unlimited) rescue MembershipPackage.first || MembershipPackage.create!(name: "Unlimited", active: true)
    @plan = membership_plans(:monthly) rescue MembershipPlan.first || MembershipPlan.create!(name: "Monthly", duration_months: 1, price: 30000, active: true)
    
    @pricing = MembershipPricing.first || MembershipPricing.create!(
      membership_package: @package,
      membership_plan: @plan,
      price: 35000
    )
  end

  test "should redirect index if unauthenticated" do
    get admin_membership_pricings_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries(2) do
      get admin_membership_pricings_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries(3) do
      get admin_membership_pricings_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:pricings)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries(4) do
      get new_admin_membership_pricing_path
    end
    assert_response :success
    assert_kind_of MembershipPricing, assigns(:pricing)
  end

  test "should create membership pricing" do
    sign_in_as(@admin)
    
    new_plan = MembershipPlan.create!(name: "Annual", duration_months: 12, price: 300000, active: true)
    
    assert_difference -> { MembershipPricing.count }, 1 do
      assert_queries(5) do
        post admin_membership_pricings_path, params: {
          membership_pricing: {
            membership_package_id: @package.id,
            membership_plan_id: new_plan.id,
            price: 300000
          }
        }
      end
    end
    
    assert_redirected_to admin_membership_pricings_path
  end

  test "should get edit" do
    sign_in_as(@admin)
    assert_queries(7) do
      get edit_admin_membership_pricing_path(@pricing)
    end
    assert_response :success
    assert_kind_of MembershipPricing, assigns(:pricing)
  end

  test "should update membership pricing" do
    sign_in_as(@admin)
    assert_queries(4) do
      patch admin_membership_pricing_path(@pricing), params: {
        membership_pricing: { price: 40000 }
      }
    end
    assert_redirected_to admin_membership_pricings_path
    @pricing.reload
    assert_equal 40000.0, @pricing.price
  end

  test "should destroy membership pricing" do
    sign_in_as(@admin)
    assert_difference -> { MembershipPricing.count }, -1 do
      assert_queries(4) do
        delete admin_membership_pricing_path(@pricing)
      end
    end
    assert_redirected_to admin_membership_pricings_path
  end
end
