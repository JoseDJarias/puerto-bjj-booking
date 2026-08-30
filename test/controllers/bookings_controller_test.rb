require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:one)
    @admin = users(:admin)
    @schedule = class_schedules(:one) # 2 hours from now
  end

  test "should redirect if not authenticated" do
    post bookings_url, params: { class_schedule_id: @schedule.id }
    assert_redirected_to new_session_url
  end

  test "should redirect if unauthorized (no membership/tickets)" do
    sign_in_as(@student)
    
    assert_queries_count(2..12) do
      post bookings_url, params: { class_schedule_id: @schedule.id }
    end
    
    assert_redirected_to root_path
    assert_equal I18n.t('bookings.messages.membership_required'), flash[:alert]
  end

  test "should create booking if authorized via ticket" do
    sign_in_as(@student)
    @student.drop_in_tickets.create!(price_paid: 20)
    
    assert_queries_count(10..40) do
      post bookings_url, params: { class_schedule_id: @schedule.id }
    end
    
    assert_response :found
    
    booking = Booking.find_by(user: @student, class_schedule: @schedule)
    assert_not_nil booking
    assert_equal "confirmed", booking.status
  end

  test "should cancel booking if already booked" do
    sign_in_as(@student)
    @student.drop_in_tickets.create!(price_paid: 20)
    Booking.create!(user: @student, class_schedule: @schedule, status: :confirmed)
    
    assert_queries_count(10..45) do
      post bookings_url, params: { class_schedule_id: @schedule.id, booking: { status: 'cancelled_user' } }
    end
    
    booking = Booking.find_by(user: @student, class_schedule: @schedule)
    assert_equal "cancelled_user", booking.status
  end
end
