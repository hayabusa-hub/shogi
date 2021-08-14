require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(name: "Example User", email: "example@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  # name のバリデーションテスト
  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end
  
  test "name length should be less than 31" do
    @user.name = "a" * 31
    assert_not @user.valid?
  end
  
  # email のバリデーションテスト
  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end
  
  test "email length should be less than 256" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "email should be downcase" do
    mixed_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_email
    @user.save
    assert_equal mixed_email.downcase, @user.reload.email
  end
  
  # パスワードのバリデーションテスト
  test "password should be present nonblank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  
  test "password lenght should be more than 5" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
