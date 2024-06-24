class UsersController < ApplicationController
  include SessionsHelper
  
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]
  
  # def index
  # end
  
  def show
    @user = User.find(params[:id])
    render json: {
      user: @user
    }
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "account created!"
      redirect_to @user
    else
      render new_user_path
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to 
    else
      render "edit"
    end
  end
  
  # def destroy
  # end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    #ログイン済みユーザーか確認する
    def logged_in_user
      if false == logged_in?
        store_location()
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end
    
    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      if false == current_user?(@user)
        redirect_to root_path
      end
    end
end
