require "test_helper"

class Admin::ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @schedule = class_schedules(:one)
    @class_type = class_types(:bjj) rescue ClassType.first
  end

  test "should redirect index if unauthenticated" do
    get admin_class_schedules_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    get admin_class_schedules_path
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get admin_class_schedules_path
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:class_schedules)
  end

  test "should get show" do
    sign_in_as(@admin)
    assert_queries_count(4..20) do
      get admin_class_schedule_path(@schedule)
    end
    assert_response :success
    assert_equal @schedule, assigns(:class_schedule)
    assert_kind_of ActiveRecord::Relation, assigns(:bookings)
    assert_kind_of ActiveRecord::Relation, assigns(:available_users)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get new_admin_class_schedule_path
    end
    assert_response :success
    assert_kind_of ClassSchedule, assigns(:class_schedule)
    assert_kind_of ActiveRecord::Relation, assigns(:class_types)
    assert_kind_of ActiveRecord::Relation, assigns(:instructors)
  end

  test "should create class schedule" do
    sign_in_as(@admin)
    assert_difference -> { ClassSchedule.count }, 1 do
      assert_queries_count(4..15) do
        post admin_class_schedules_path, params: {
          class_schedule: {
            class_type_id: @class_type.id,
            instructor_id: @admin.id,
            starts_at: Time.current + 1.day,
            duration_minutes: 60,
            capacity: 20
          }
        }
      end
    end
    assert_redirected_to admin_class_schedules_path
  end

  test "should get attendance" do
    sign_in_as(@admin)
    assert_queries_count(4..15) do
      get attendance_admin_class_schedule_path(@schedule)
    end
    assert_response :success
    assert_kind_of ActiveRecord::Relation, assigns(:bookings)
    assert_kind_of ActiveRecord::Relation, assigns(:available_users)
  end

  test "should get batch_new" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get batch_new_admin_class_schedules_path
    end
    assert_response :success
    assert_kind_of ClassSchedule, assigns(:class_schedule)
    assert_kind_of Date, assigns(:default_start)
    assert_kind_of Date, assigns(:default_end)
  end
end
