class MatchsController < ApplicationController
  
  include SessionsHelper
  include GamesHelper
  
  before_action :init
  # before_action :update_user_list, only: [:update_info, :request_match, :accept_match, :decline_match]
  
  # loginユーザーとparams[:id]が一致しているかチェックする
  def init
    @user = current_user()
  end
  
  # def update_user_list
  #   @opp_user = User.find_by(id: params[:from_id])
  #   @opponent = Match.find_by(opponent_id: @user.id, status: WAITING)
  #   @match = Match.find_by(user_id: @user.id)
  #   @matches = Match.where(status: STANDBY).paginate(page: params[:page])
  # end
  
  def index()
    @opponent = Match.find_by(opponent_id: @user.id)
    @match = Match.find_by(user_id: @user.id)
    @matches = Match.where(status: STANDBY).paginate(page: params[:page])
    
    #対局する場合、GAME画面へ移動する
    if(@match != nil) && (PLAYING == @match.status)
      redirect_to game_path(@match.game_id)
    end
  end
  
  def create
    @match = Match.new(user_id: params[:user_id])
    if @match.save
      # 入室の旨をチャット参加者に配信
      broadcast(@match.user_id)
      
      flash[:info] = "対局室へ移動しました"
      redirect_to matchs_path
    elsif Match.find_by(user_id: params[:user_id])
      flash[:info] = "すでに対局室へいます"
      redirect_to matchs_path
    else
      flash[:danger] = "対局室への移動へ失敗しました"
      redirect_to root_path
    end
  end
  
  def edit
  end
  
  def update
    
    @match = Match.find_by(user_id: @user.id)
    @opponent = Match.find_by(user_id: params[:opponent_id])
    
    #対戦要求を出した場合
    if(REQUEST == params[:status].to_i)
      if(STANDBY == @opponent.status)
        opp = User.find_by(id: params[:opponent_id])
        if(STANDBY == @match.status)
          #状態を更新
          @match.opponent_id = params[:opponent_id]
          @match.status = REQUEST
          @match.save
          @opponent.opponent_id = @match.user_id
          @opponent.status = WAITING
          @opponent.save
          
          msg = "#{opp.name}へ対戦要求を出しました"
          broadcast(@opponent.user_id)
        elsif(REQUEST == @match.status)
          msg = "複数の対戦要求を出すことはできません"
        elsif(WAITING == @match.status)
          msg = "既に#{opp.name}から対戦要求が出されています"
        else
          #ここにはこない
          5.times {puts "********* @match.status is invalid value: #{@match.status} ***********"}
        end
      else
        @match.opponent_id = 0
        @match.status = STANDBY
        @match.save
        msg = "別の人が対戦要求を出しています"
      end
    else
      
      #対戦要求を拒否した場合
      if(DECLINE == params[:status].to_i)
        #状態を更新
        @match.status = STANDBY
        @match.opponent_id = 0
        @match.save
        @opponent.status = STANDBY
        @opponent.opponent_id = 0
        @opponent.save
        
        msg = "対戦要求を拒否しました"
        broadcast(@opponent.user_id)
      #対戦要求を承諾した場合
      elsif(PLAYING == params[:status].to_i)
        #状態を更新
        @match.opponent_id = params[:opponent_id]
        @match.status = PLAYING
        @opponent.status = PLAYING
        
        #ゲームモデルを作成
        game_id = make_game(@match.user, @opponent.user)
        @match.game_id = game_id
        @opponent.game_id = game_id
        
        #保存
        @match.save
        @opponent.save
        
        msg = "対局開始！！！"
        broadcast(@opponent.user_id, true)
      end
    end
    
    #モデルの保存
    # @match.save
    # @opponent.save
    
    #更新した旨を通知
    #broadcast(@match.user_id, type)
    
    #フラッシュメッセージの表示
    flash[:info] = msg
    
    #リダイレクト
    redirect_to matchs_path
    # update_info()
    
    # @opponent = Match.find(params[:id])
    # @opponent.opponent_id = params[:opponent_id]
    # @opponent.status = params[:status]
    # if @opponent.save
    # else
    # end
    
    # # respond_to do |format|
    # #   format.html { redirect_to @match }
    # #   format.js
    # # end
    
    # #更新した旨を表示
    # #broadcast(@match.user_id)
    
    # if @opponent.status == 1
    #   opp = User.find(@opponent.opponent_id)
    #   flash[:success] = "#{opp.name}へ対戦要求を出しました"
    #   redirect_to matchs_path
    # elsif @opponent.status == 3
    #   @match = Match.find(@user.match.id)
    #   @match.opponent_id = @opponent.user_id
    #   @match.status = 3
    #   if @match.save
    #     flash[:success] = "対局開始！！！"
    #     render "shared/_game_create"
    #     # redirect_to games_path, method: :post
    #   else
    #     flash[:danger] = "対戦できませんでした"
    #     redirect_to matchs_path
    #   end
    # end 
  end
  
  def destroy
    
    # 削除対象のインスタンスを取得
    @match = Match.find(@user.match.id)
    
    #インスタンスを削除する
    @match.destroy
    @match.save
    flash[:info] = "対局室から退室しました"
    
    # 退出の旨をチャット参加者に配信
    broadcast()
    
    redirect_to root_path
  end
  
  def update_info
    # if @user.id != params[:id].to_i
    @opponent = Match.find_by(opponent_id: @user.id, status: WAITING)
    @match = Match.find_by(user_id: @user.id)
    @matches = Match.where(status: STANDBY)
    # debugger
    # 5.times {puts "********* match_opponent: #{@opponent} update_info js ***********"}
    
    respond_to do |format|
      format.js { render 'matchs/update_info.js.erb'}
    end
    
    
    
    # end
    
    # if @user.id != params[:id].to_i
    #   respond_to do |format|
    #     # format.html {redirect_to matchs_path}
    #     format.js {5.times {puts "********* user_id: #{@user.id} update_info js ***********"} #debug用
    #       render 'matchs/update_info.js.erb'}
    #   end
    # end
  end
  
  # def request_match
  #   if @user.id == params[:id].to_i
  #     @match.opponent_id = @opp_user.id
  #     @match.status = WAITING
  #     @match.save
  #   end
  #   respond_to do |format|
  #     format.js { render 'matchs/update_info.js.erb'}
  #   end
  # end
  
  # def accept_match
  #   if @user.id == params[:id].to_i
  #     @match.status = PLAYING
  #     @match.game_id = @opp_user.match.game_id
  #     @match.save
  #   end
  #   respond_to do |format|
  #     format.js { render 'matchs/update_info.js.erb'}
  #   end
  # end
  
  # def decline_match
  #   if @user.id == params[:id].to_i
  #     @match.status = STANDBY
  #     @match.save
  #   end
  #   respond_to do |format|
  #     format.js { render 'matchs/update_info.js.erb'}
  #   end
  # end
  
  private
  
    def match_params
     params.require(:match).permit(:id, :opponent_id, :status)
    end
   
    def make_game(user1, user2)
      game = Game.new()
      first, second = make_turn(user1, user2)
      game.board_init(first, second)
      return game.id
    end
   
    def make_turn(user1, user2)
      tmp = rand(2)
      if(tmp == 0)
        a = user1.name
        b = user2.name
      else
        a = user2.name
        b = user1.name
      end
      return a, b
    end
    
    def broadcast(id=0, reload=false)
      
      data = {}
      data[:from_id] = @user.id
      data[:to_id]   = id
      data[:reload]  = reload
      
      # チャット参加者に配信
      ActionCable.server.broadcast('match_channel', data: data)
    end
end
