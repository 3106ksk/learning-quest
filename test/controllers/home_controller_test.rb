require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "should get index" do
    get home_url
    assert_response :success
  end
end
