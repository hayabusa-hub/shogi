require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: { user: { name: "",
                                         email: "user@example.com",
                                         password: "aaa",
                                         password_confirmation: "bbb"} }
    end
    assert_template "users/new"
    assert_select 'div#error_explanation', /.*/
    assert_select 'div.alert', /.*/
    assert_select 'div.alert-danger', /.*/
    # assert_not flash[:danger].empty?
  end
  
  test "valid signup information" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "aaa",
                                         email: "aaa@example.com",
                                         password: "aaaaaa",
                                         password_confirmation: "aaaaaa"} }
    end
    follow_redirect!
    assert_template "users/show"
    assert_select 'div#error_explanation', count: 0
    assert_not flash[:success].empty?
  end
end
