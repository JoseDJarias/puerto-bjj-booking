require "test_helper"

class MembershipInfoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:one)
  end

  test "should redirect show if unauthenticated" do
    get my_membership_url
    assert_redirected_to new_session_url
  end

  test "should redirect history if unauthenticated" do
    get my_membership_history_url
    assert_redirected_to new_session_url
  end

  test "should get show with active memberships" do
    sign_in_as(@student)
    
    # We can create a membership
    package = membership_packages(:unlimited) rescue MembershipPackage.first
    plan = membership_plans(:monthly) rescue MembershipPlan.first
    if package && plan
      @student.memberships.create!(membership_package: package, membership_plan: plan, start_date: Date.current, end_date: 1.month.from_now, amount_paid: 100)
    end
    
    assert_queries_count(2..10) do
      get my_membership_url
    end
    
    assert_response :success
    assert_not_nil assigns(:current_memberships)
    assert_not_nil assigns(:unused_drop_in_count)
    assert_not_nil assigns(:drop_in_active_today)
  end

  test "should get show when null (no memberships)" do
    sign_in_as(@student)
    # student has no memberships by default in fixtures
    
    assert_queries_count(2..8) do
      get my_membership_url
    end
    
    assert_response :success
    assert_equal 0, assigns(:current_memberships).size
    assert_equal 0, assigns(:unused_drop_in_count)
    assert_equal false, assigns(:drop_in_active_today)
  end

  test "should get history" do
    sign_in_as(@student)
    
    assert_queries_count(2..8) do
      get my_membership_history_url
    end
    
    assert_response :success
    assert_not_nil assigns(:past_memberships)
    assert_not_nil assigns(:drop_in_history)
  end
end
