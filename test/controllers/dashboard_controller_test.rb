require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:one)
    @admin = users(:admin)
    
    # We need to create a pending user dynamically as fixtures don't have one
    @pending_user = User.create!(
      first_name: "Pending",
      last_name: "User",
      email_address: "pending@puertobjj.com",
      password: "password123",
      identification: "999999999",
      role: :member,
      status: :active,
      approved_at: nil
    )
  end

  test "should redirect to login when unauthenticated" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "should get show for approved user without booking access" do
    sign_in_as(@student)
    
    assert_queries(17) do
      get root_url
    end
    
    assert_response :success
    
    # Assert Data Structures
    assert_kind_of ActiveRecord::Relation, assigns(:packages)
    assert_kind_of ActiveRecord::Relation, assigns(:plans)
    assert_includes assigns(:packages).first.class.name, "MembershipPackage" if assigns(:packages).any?
    
    assert_includes [true, false], assigns(:is_first_time)
    assert_nil assigns(:upcoming_bookings)
  end

  test "should get show for student with booking access" do
    sign_in_as(@student)
    
    @student.drop_in_tickets.create!(price_paid: 20)
    
    class_schedule = class_schedules(:one) rescue ClassSchedule.first
    if class_schedule
      @student.bookings.create!(class_schedule: class_schedule, status: :confirmed)
    end
    
    assert_queries(25) do
      get root_url
    end
    
    assert_response :success
    
    # Assert Data Structures and Types
    assert_kind_of ActiveRecord::Relation, assigns(:upcoming_bookings)
    assert_kind_of ActiveRecord::Relation, assigns(:past_bookings)
    assert_kind_of Integer, assigns(:total_attended)
    assert_kind_of Integer, assigns(:month_attended)
    assert_kind_of ActiveRecord::Relation, assigns(:active_memberships)
    assert_kind_of Integer, assigns(:unused_tickets_count)
    
    # Assert specific timezone and logic
    assert_operator assigns(:month_attended), :>=, 0
    assert_operator assigns(:total_attended), :>=, assigns(:month_attended)
  end

  test "should get show for pending user" do
    sign_in_as(@pending_user)
    
    assert_queries(3) do
      get root_url
    end
    
    assert_response :success
    assert_nil assigns(:upcoming_bookings)
    assert_nil assigns(:packages)
  end
end
