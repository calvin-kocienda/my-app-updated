require "test_helper"

class OrderscreenControllerTest < ActionDispatch::IntegrationTest
  test "should get apples:int" do
    get orderscreen_apples:int_url
    assert_response :success
  end

  test "should get oranges:int" do
    get orderscreen_oranges:int_url
    assert_response :success
  end

  test "should get bananas:int" do
    get orderscreen_bananas:int_url
    assert_response :success
  end

  test "should get peaches:int" do
    get orderscreen_peaches:int_url
    assert_response :success
  end
end
