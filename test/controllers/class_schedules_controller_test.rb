require "test_helper"

class ClassSchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:one)
    @admin = users(:admin)
    @schedule = class_schedules(:one)
  end

  test "should redirect show if unauthenticated" do
    get class_schedule_url(@schedule)
    assert_redirected_to new_session_url
  end

  test "should redirect show if no booking access" do
    sign_in_as(@student)
    
    assert_queries_count(4..10) do
      get class_schedule_url(@schedule)
    end
    assert_redirected_to root_path
  end

  test "should get show if authorized" do
    sign_in_as(@student)
    @student.drop_in_tickets.create!(price_paid: 20) # Grants booking access
    
    assert_queries_count(5..15) do
      get class_schedule_url(@schedule)
    end
    
    assert_response :success
    assert_not_nil assigns(:schedule)
  end

  test "should allow instructor or admin to update notes" do
    sign_in_as(@admin)
    
    assert_queries_count(2..15) do
      patch class_schedule_url(@schedule), params: { class_schedule: { topic: "Guard Retention", notes: "Bring gi" } }
    end
    
    assert_redirected_to class_schedule_path(@schedule)
    @schedule.reload
    assert_equal "Guard Retention", @schedule.topic
    assert_equal "Bring gi", @schedule.notes
  end

  test "should not allow student to update notes" do
    sign_in_as(@student)
    @student.drop_in_tickets.create!(price_paid: 20) # Grants booking access
    
    patch class_schedule_url(@schedule), params: { class_schedule: { topic: "Hacked" } }
    
    assert_redirected_to root_path
    @schedule.reload
    assert_not_equal "Hacked", @schedule.topic
  end

  test "should get participants list" do
    sign_in_as(@admin)
    
    assert_queries_count(2..10) do
      get participants_class_schedule_url(@schedule)
    end
    
    assert_response :success
    assert_not_nil assigns(:schedule)
  end
end
