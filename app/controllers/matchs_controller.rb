class MatchsController < ApplicationController
  
  # loginユーザーとparams[:id]が一致しているかチェックする
  before_action :init
  
  include SessionsHelper
  
  def init
    @user = current_user()
  end
  
  def index
    # @user = current_user()
    @opponent = Match.find_by(opponent_id: @user.id, status: 1)
    @match = Match.find_by(user_id: @user.id)
    @matches = Match.where(status: 0).paginate(page: params[:page])
    
    if @match.status == 2
      flash[:danger] = "対戦要求を拒否されました"
      @match.status = 1
      @match.opponent_id = 0
      @match.save
    end
  end
  
  def create
    @match = Match.new(user_id: params[:user_id])
    if @match.save
      flash[:success] = "対局室へ移動しました"
      
      # 入室の旨をチャット参加者に配信
      broadcast(@match.user_id)
      
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
    @opponent = Match.find(params[:id])
    @opponent.opponent_id = params[:opponent_id]
    @opponent.status = params[:status]
    if @opponent.save
    else
    end
    
    # respond_to do |format|
    #   format.html { redirect_to @match }
    #   format.js
    # end
    
    #更新した旨を表示
    #broadcast(@match.user_id)
    
    if @opponent.status == 1
      opp = User.find(@opponent.opponent_id)
      flash[:success] = "#{opp.name}へ対戦要求を出しました"
      redirect_to matchs_path
    elsif @opponent.status == 3
      @match = Match.find(@user.match.id)
      @match.opponent_id = @opponent.user_id
      @match.status = 3
      if @match.save
        flash[:success] = "対局開始！！！"
        render "shared/_game_create"
        # redirect_to games_path, method: :post
      else
        flash[:danger] = "対戦できませんでした"
        redirect_to matchs_path
      end
    end 
  end
  
  def destroy
    
    # 削除対象のインスタンスを取得
    @match = Match.find(@user.match.id)
    
    # 退出の旨をチャット参加者に配信
    broadcast(@match.user_id)
    
    #インスタンスを削除する
    @match.destroy
    flash[:success] = "対局室から退室しました"
    
    redirect_to root_path
  end
  
  private
  
   def match_params
    params.require(:match).permit(:id, :opponent_id, :status)
   end
   
   def broadcast(id)
     
     # チャット参加者に配信
     ActionCable.server.broadcast('match_channel', user_id: id)
   end
end
