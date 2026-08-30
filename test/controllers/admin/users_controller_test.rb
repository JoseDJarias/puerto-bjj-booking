require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:one)
  end

  test "should redirect index if unauthenticated" do
    get admin_users_path
    assert_redirected_to new_session_url
  end

  test "should redirect index if not admin" do
    sign_in_as(@student)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "should get index" do
    sign_in_as(@admin)
    assert_queries_count(2..12) do
      get admin_users_path
    end
    assert_response :success
    assert_kind_of Array, assigns(:users)
    assert_kind_of User::UserStats, assigns(:stats)
  end

  test "should get show" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      get admin_user_path(@student)
    end
    assert_response :success
    assert_equal @student, assigns(:user)
    assert_kind_of ActiveRecord::Relation, assigns(:memberships)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries_count(1..5) do
      get new_admin_user_path
    end
    assert_response :success
    assert_kind_of User, assigns(:user)
  end

  test "should create user" do
    sign_in_as(@admin)
    assert_difference -> { User.count }, 1 do
      assert_queries_count(2..12) do
        post admin_users_path, params: {
          user: {
            first_name: "Test",
            last_name: "User",
            email_address: "test@example.com",
            identification: "555555555",
            password: "password",
            password_confirmation: "password"
          }
        }
      end
    end
    assert_redirected_to admin_user_path(User.last)
  end

  test "should update user" do
    sign_in_as(@admin)
    assert_queries_count(2..10) do
      patch admin_user_path(@student), params: { user: { first_name: "Updated Name" } }
    end
    assert_redirected_to admin_users_path
    @student.reload
    assert_equal "Updated Name", @student.first_name
  end

  test "should approve user" do
    sign_in_as(@admin)
    pending_user = User.create!(
      first_name: "Pending", last_name: "User", email_address: "pend@example.com",
      password: "password123", identification: "999999999", role: :member, status: :active, approved_at: nil
    )
    
    assert_queries_count(2..10) do
      patch approve_admin_user_path(pending_user)
    end
    
    assert_redirected_to admin_users_path
    pending_user.reload
    assert_not_nil pending_user.approved_at
  end

  test "should destroy user" do
    sign_in_as(@admin)
    assert_difference -> { User.count }, -1 do
      assert_queries_count(2..10) do
        delete admin_user_path(@student)
      end
    end
    assert_redirected_to admin_users_path
  end
end
