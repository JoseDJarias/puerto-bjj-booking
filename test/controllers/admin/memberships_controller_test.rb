require "test_helper"

class Admin::MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @membership = memberships(:one) rescue nil
    
    if @membership.nil?
      package = membership_packages(:unlimited) rescue MembershipPackage.first
      plan = membership_plans(:monthly) rescue MembershipPlan.first
      @membership = Membership.create!(
        user: @student,
        membership_package: package,
        membership_plan: plan,
        start_date: Date.current,
        end_date: 1.month.from_now,
        amount_paid: 50000,
        status: :active
      )
    end
  end

  test "should redirect index if unauthenticated" do
    get admin_memberships_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    assert_queries(2) do
      get admin_memberships_path
    end
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries(8) do
      get admin_memberships_path
    end
    assert_response :success
    assert_kind_of Array, assigns(:memberships)
    assert_kind_of Struct, assigns(:stats)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries(5) do
      get new_admin_membership_path
    end
    assert_response :success
    assert_kind_of Membership, assigns(:membership)
    assert_kind_of ActiveRecord::Relation, assigns(:plans)
    assert_kind_of ActiveRecord::Relation, assigns(:packages)
    assert_kind_of ActiveRecord::Relation, assigns(:users)
  end

  test "should create membership" do
    sign_in_as(@admin)
    
    package = MembershipPackage.first
    plan = MembershipPlan.first
    
    assert_difference -> { Membership.count }, 1 do
      assert_queries(6) do
        post admin_memberships_path, params: {
          membership: {
            user_id: @student.id,
            membership_package_id: package.id,
            membership_plan_id: plan.id,
            start_date: Date.current,
            amount_paid: 10000
          }
        }
      end
    end
    
    assert_redirected_to admin_user_path(@student)
  end

  test "should get edit" do
    sign_in_as(@admin)
    assert_queries(6) do
      get edit_admin_membership_path(@membership)
    end
    assert_response :success
    assert_kind_of Membership, assigns(:membership)
  end

  test "should update membership" do
    sign_in_as(@admin)
    assert_queries(4) do
      patch admin_membership_path(@membership), params: {
        membership: { amount_paid: 99999 }
      }
    end
    assert_redirected_to admin_memberships_path
    @membership.reload
    assert_equal 99999.0, @membership.amount_paid
  end

  test "should destroy membership" do
    sign_in_as(@admin)
    assert_difference -> { Membership.count }, -1 do
      assert_queries(4) do
        delete admin_membership_path(@membership)
      end
    end
    assert_redirected_to admin_memberships_path
  end

  test "should calculate totals" do
    sign_in_as(@admin)
    
    package = MembershipPackage.first
    plan = MembershipPlan.first
    
    assert_queries(4) do
      get calculate_totals_admin_memberships_path, params: {
        membership: {
          membership_package_id: package.id,
          membership_plan_id: plan.id,
          start_date: Date.current
        }
      }
    end
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_includes json_response, "amount"
    assert_includes json_response, "end_date"
  end
end
