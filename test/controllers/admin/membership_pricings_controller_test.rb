require "test_helper"

class Admin::MembershipPricingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_membership_pricings_index_url
    assert_response :success
  end
end
