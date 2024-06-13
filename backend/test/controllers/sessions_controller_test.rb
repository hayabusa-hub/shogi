require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_path
    assert_response :success
  end
  
  test "should post create" do
    # post login_path
    # assert_response :success
  end
  
  test "should delete destroy" do
    # delete logout_path
    # assert_response :success
  end

end
