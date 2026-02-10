require "test_helper"

class Admin::MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_memberships_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_memberships_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_memberships_edit_url
    assert_response :success
  end
end
