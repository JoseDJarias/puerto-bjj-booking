require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to admin_dashboard_path
    assert cookies[:session_id]
  end

  test "create with remember_me sets permanent cookie" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "password",
      remember_me: "1"
    }

    assert_redirected_to admin_dashboard_path
    set_cookies = Array(response.headers["Set-Cookie"])
    session_id_cookie = set_cookies.find { |c| c.start_with?("session_id=") }
    assert session_id_cookie, "Expected Set-Cookie for session_id"
    assert_includes session_id_cookie, "expires=", "Remember me should set permanent cookie with expiry"
  end

  test "create without remember_me sets session cookie" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "password",
      remember_me: "0"
    }

    assert_redirected_to admin_dashboard_path
    set_cookies = Array(response.headers["Set-Cookie"])
    session_id_cookie = set_cookies.find { |c| c.start_with?("session_id=") }
    assert session_id_cookie, "Expected Set-Cookie for session_id"
    assert_not_includes session_id_cookie, "expires=", "Without remember me should set session cookie without expiry"
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
