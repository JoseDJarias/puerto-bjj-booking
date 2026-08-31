require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:one)
    @user = users(:one) # Belongs to group one
    sign_in_as(@user)
  end

  test "should get index and avoid N+1" do
    assert_queries(6) do
      get groups_url
    end
    assert_response :success
    assert_not_nil assigns(:accepted_groups)
    assert_not_nil assigns(:invited_groups)
  end

  test "should get show if accepted and avoid N+1" do
    assert_queries(11) do
      get group_url(@group)
    end
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should not get show if not member" do
    other_user = users(:two)
    sign_in_as(other_user) # Not a member of group one

    assert_queries(4) do
      get group_url(@group)
    end
    assert_redirected_to groups_url
    assert_equal "No tienes permiso para ver este grupo.", flash[:alert]
  end

  test "should not get show if invited but not accepted" do
    group_two = groups(:two)
    other_user = users(:two)
    sign_in_as(other_user) # Invited to group two

    assert_queries(5) do
      get group_url(group_two)
    end
    assert_redirected_to groups_url
    assert_equal "Debes aceptar la invitación primero.", flash[:alert]
  end
end
