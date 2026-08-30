require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    # Give the admin a schedule to test if the schedules array is populated
    class_schedules(:one).update(starts_at: ClassSchedule.logical_today + 12.hours, instructor: @admin)
  end

  test "should redirect index if unauthenticated" do
    get admin_dashboard_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin or instructor" do
    sign_in_as(@student)
    
    assert_queries_count(2..10) do
      get admin_dashboard_path
    end
    assert_redirected_to root_path
  end

  test "should get index for admin with queries and data structures asserted" do
    sign_in_as(@admin)
    
    assert_queries_count(4..15) do
      get admin_dashboard_path
    end
    
    assert_response :success
    
    # Assert data structures
    assert_kind_of Date, assigns(:base_date)
    assert_kind_of Date, assigns(:date)
    assert_kind_of Integer, assigns(:offset)
    assert_equal 0, assigns(:offset)
    assert_equal assigns(:base_date), assigns(:date)
    
    assert_kind_of ActiveRecord::Relation, assigns(:schedules)
    assert_kind_of Integer, assigns(:pending_approvals)
    assert_operator assigns(:pending_approvals), :>=, 0
  end

  test "should get index for admin with offset date" do
    sign_in_as(@admin)
    
    assert_queries_count(4..15) do
      get admin_dashboard_path(offset: 1)
    end
    
    assert_response :success
    assert_equal 1, assigns(:offset)
    assert_equal assigns(:base_date) + 1.day, assigns(:date)
    
    # Nullability: The schedule array might be empty for tomorrow
    assert_kind_of ActiveRecord::Relation, assigns(:schedules)
  end
end
