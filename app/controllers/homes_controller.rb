class HomesController < ApplicationController
  
  include SessionsHelper
  
  def top
    if logged_in?
      @user = User.find(current_user.id)
    end
  end
  
end
