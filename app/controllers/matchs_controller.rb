class MatchsController < ApplicationController
  
  include SessionsHelper
  
  def index
    @user = current_user()
    @matches = Match.where(status: 0).paginate(page: params[:page])
  end
  
  def create
    @match = Match.new(user_id: params[:user_id])
    if @match.save
      flash[:success] = "対局室へ移動しました"
      redirect_to matchs_path
    elsif Match.find_by(user_id: params[:user_id])
      flash[:danger] = "すでに対局室へいます"
      redirect_to matchs_path
    else
      flash[:danger] = "対局室への移動へ失敗しました"
      redirect_to root_path
    end
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
end
