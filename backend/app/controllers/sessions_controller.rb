class SessionsController < ApplicationController
  
  include SessionsHelper
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      remember(user)
    end
    render json: outputType()
  end
  
  def destroy
    log_out() if logged_in?
    render json: outputType()
  end

  def isLogin?
    render json: outputType()
  end

  private 
    def outputType()
      user = current_user
      ret = {
        isLogin:   user ? true       : false,
        userId:    user ? user.id    : nil,
        userName:  user ? user.name  : nil,
        userEmail: user ? user.email : nil
      }
    end
end
