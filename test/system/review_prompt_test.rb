require "application_system_test_case"

class ReviewPromptTest < ApplicationSystemTestCase
  test "showing the review prompt for eligible users" do
    user = users(:admin) # Admin bypasses membership restriction
    
    # Simulate 3 attended bookings so the user is eligible
    user.bookings.find_or_create_by!(class_schedule: class_schedules(:one)).update!(status: :attended)
    user.bookings.find_or_create_by!(class_schedule: class_schedules(:two)).update!(status: :attended)
    user.bookings.find_or_create_by!(class_schedule: class_schedules(:three)).update!(status: :attended)
    
    # Login via UI
    visit new_session_path
    fill_in "Correo electrónico", with: user.email_address
    fill_in "Contraseña", with: "password" # From fixtures
    click_button "Iniciar sesión"

    # Wait for login to complete before navigating away (fixes Capybara race condition)
    assert_current_path admin_dashboard_path

    # Admin is redirected to admin dashboard, so we visit the normal dashboard
    visit root_path
    
    puts page.html

    # Verify the banner exists
    assert_text "¡Nos encanta verte entrenar en nuestra nueva sede!", wait: 10

    # Take a screenshot to show the user
    take_screenshot
  end
end
