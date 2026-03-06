require "test_helper"

class DogFightsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dog_fights_show_url
    assert_response :success
  end
end
