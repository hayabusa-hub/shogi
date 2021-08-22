require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  include SessionsHelper
  
  def setup
    @user = users(:michael)
  end
  
  test "login with invalid information" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: { email: "", password: ""} }
    assert_template "sessions/new"
    assert_not flash[:danger].empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information" do
    get login_path
    #ログインする
    post login_path, params: { session: { email: @user.email,
                                          password: "password" } }
    follow_redirect!
    assert session[:user_id]
    
    #ログアウトする
    delete logout_path
    # assert_not logged_in?
  end
end
