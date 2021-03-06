require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:alice) 
  end
  
  test "unsuccessful edit" do
    login_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar"} }
    assert_template "users/edit"
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    login_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: ""} }
    assert flash.present?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert flash.present?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    login_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email} }
    assert flash.present?
    assert_redirected_to root_path
  end
end
