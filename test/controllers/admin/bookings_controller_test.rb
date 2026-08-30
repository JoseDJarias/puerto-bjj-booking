require "test_helper"

class Admin::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
    @schedule = class_schedules(:one)
    @booking = bookings(:one) rescue Booking.first
    if @booking.nil?
      @booking = Booking.create!(user: @student, class_schedule: @schedule, status: :confirmed)
    end
  end

  test "should redirect create if unauthenticated" do
    post admin_bookings_path
    assert_redirected_to new_session_url
  end

  test "should redirect create if not admin" do
    sign_in_as(@student)
    post admin_bookings_path
    assert_redirected_to root_path
  end

  test "should create booking (admin adding student)" do
    sign_in_as(@admin)
    
    new_student = users(:two)
    
    assert_difference -> { Booking.count }, 1 do
      assert_queries_count(4..25) do
        post admin_bookings_path, params: {
          booking: {
            user_id: new_student.id,
            class_schedule_id: @schedule.id
          }
        }
      end
    end
    assert_redirected_to attendance_admin_class_schedule_path(@schedule)
    assert_kind_of Booking, assigns(:booking)
    assert_equal "confirmed", assigns(:booking).status
  end

  test "should update booking (toggle block)" do
    sign_in_as(@admin)
    assert_queries_count(4..20) do
      patch admin_booking_path(@booking), params: { action_type: "toggle_block" }
    end
    assert_redirected_to admin_dashboard_path
    @booking.reload
    assert_equal "blocked", @booking.status
  end

  test "should toggle attendance (check-in)" do
    sign_in_as(@admin)
    @booking.update!(status: :confirmed)
    
    assert_queries_count(4..30) do
      patch toggle_attendance_admin_booking_path(@booking)
    end
    assert_redirected_to admin_class_schedule_path(@booking.class_schedule)
    @booking.reload
    assert_equal "attended", @booking.status
  end

  test "should destroy booking (cancel by admin)" do
    sign_in_as(@admin)
    
    assert_no_difference -> { Booking.count } do
      assert_queries_count(4..15) do
        delete admin_booking_path(@booking)
      end
    end
    assert_redirected_to admin_dashboard_path
    @booking.reload
    assert_equal "cancelled_admin", @booking.status
  end
end
