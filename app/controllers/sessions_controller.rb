class SessionsController < ApplicationController
  
  include SessionsHelper
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      flash[:success] = "successed to login"
      redirect_to(root_path)
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "sessions/new"
    end
  end
  
  def destroy
    log_out()
    redirect_to root_path
  end
end
