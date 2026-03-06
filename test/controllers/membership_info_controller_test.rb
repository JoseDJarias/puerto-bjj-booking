require "test_helper"

class MembershipInfoControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get membership_info_show_url
    assert_response :success
  end
end
