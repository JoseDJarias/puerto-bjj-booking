require "test_helper"

class Admin::GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @instructor = users(:instructor)
    @group = groups(:one) # created by admin
    @group_two = groups(:two) # created by instructor
  end

  test "admin should get index and see all groups without N+1" do
    sign_in_as(@admin)
    assert_queries(5) do
      get admin_groups_url
    end
    assert_response :success
    assert_equal 2, assigns(:groups).size
  end

  test "instructor should get index and see only their groups without N+1" do
    sign_in_as(@instructor)
    assert_queries(5) do
      get admin_groups_url
    end
    assert_response :success
    assert_equal 1, assigns(:groups).size
    assert_equal @group_two, assigns(:groups).first
  end

  test "should get show and avoid N+1" do
    sign_in_as(@admin)
    assert_queries(12) do
      get admin_group_url(@group)
    end
    assert_response :success
    assert_not_nil assigns(:messages)
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    sign_in_as(@admin)
    assert_queries(2) do
      get new_admin_group_url
    end
    assert_response :success
  end

  test "should create group" do
    sign_in_as(@admin)
    assert_difference("Group.count") do
      assert_queries(4) do
        post admin_groups_url, params: { group: { name: "Nuevo Grupo", description: "Descripción" } }
      end
    end
    assert_redirected_to admin_groups_url
    assert_equal @admin, Group.last.creator
  end

  test "should update group" do
    sign_in_as(@admin)
    patch admin_group_url(@group), params: { group: { name: "Updated" } }
    assert_redirected_to admin_groups_url
    @group.reload
    assert_equal "Updated", @group.name
  end

  test "should destroy group" do
    sign_in_as(@admin)
    assert_difference -> { Group.count }, -1 do
      Bullet.enable = false if defined?(Bullet)
      assert_queries(13) do
        delete admin_group_url(@group)
      end
      Bullet.enable = true if defined?(Bullet)
    end
    assert_redirected_to admin_groups_url
  end
end
