require "test_helper"

class Admin::MembershipPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @plan = membership_plans(:monthly) rescue nil
    
    if @plan.nil?
      @plan = MembershipPlan.create!(name: "Monthly", duration_months: 1, price: 30000, active: true)
    end
  end

  test "should redirect index if unauthenticated" do
    get admin_membership_plans_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries(2) do
      get admin_membership_plans_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries(3) do
      get admin_membership_plans_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:membership_plans)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries(2) do
      get new_admin_membership_plan_path
    end
    assert_response :success
    assert_kind_of MembershipPlan, assigns(:membership_plan)
  end

  test "should create membership plan" do
    sign_in_as(@admin)
    
    assert_difference -> { MembershipPlan.count }, 1 do
      assert_queries(3) do
        post admin_membership_plans_path, params: {
          membership_plan: {
            name: "Annual",
            duration_months: 12,
            price: 300000,
            active: true
          }
        }
      end
    end
    
    assert_redirected_to admin_membership_plans_path
  end

  test "should get edit" do
    sign_in_as(@admin)
    assert_queries(3) do
      get edit_admin_membership_plan_path(@plan)
    end
    assert_response :success
    assert_kind_of MembershipPlan, assigns(:membership_plan)
  end

  test "should update membership plan" do
    sign_in_as(@admin)
    assert_queries(4) do
      patch admin_membership_plan_path(@plan), params: {
        membership_plan: { name: "Updated Monthly" }
      }
    end
    assert_redirected_to admin_membership_plans_path
    @plan.reload
    assert_equal "Updated Monthly", @plan.name
  end
end
