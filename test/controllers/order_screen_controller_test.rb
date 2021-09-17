require "test_helper"

class OrderScreenControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get order_screen_index_url
    assert_response :success
  end
end
