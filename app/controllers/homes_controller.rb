class HomesController < ApplicationController
  
  include SessionsHelper
  
  def top
    if logged_in?
      @user = User.find(current_user.id)
      @match = Match.find_by(user_id: @user.id)
    end
  end
  
end
