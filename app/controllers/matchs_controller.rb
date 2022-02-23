class MatchsController < ApplicationController
  
  # loginユーザーとparams[:id]が一致しているかチェックする
  before_action :init
  
  include SessionsHelper
  
  def init
    @user = current_user()
  end
  
  def index()
    @opponent = Match.find_by(opponent_id: @user.id, status: WAITING)
    @match = Match.find_by(user_id: @user.id)
    @matches = Match.where(status: STANDBY).paginate(page: params[:page])
    
    #対局する場合、GAME画面へ移動する
    if(PLAYING == @match.status)
      redirect_to game_path(@match.game_id)
    end
    
    # if @match.status == 2
    #   flash[:danger] = "対戦要求を拒否されました"
    #   @match.status = 1
    #   @match.opponent_id = 0
    #   @match.save
    # end
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
    @match.opponent_id = params[:opponent_id]
    @match.status = params[:status]
    
    @opponent = Match.find_by(user_id: params[:opponent_id])
    @opponent.opponent_id = @match.user_id
    
    #対戦要求を出した場合
    if(WAITING == @match.status)
      opp = User.find(@match.opponent_id)
      msg = "#{opp.name}へ対戦要求を出しました"
    else
      
      #対戦要求を拒否した場合
      if(DECLINE == @match.status)
        #状態を更新
        @match.status = STANDBY
        @opponent.status = STANDBY
        
        msg = "対戦要求を拒否されました"
        
      #対戦要求を承諾した場合
      elsif(PLAYING == @match.status)
        #状態を更新
        @opponent.status = PLAYING
        
        msg = "対局開始！！！"
        
        #ゲームモデルを作成
        game_id = make_game(@match.user_id, @opponent.user_id)
        @match.game_id = game_id
        @opponent.game_id = game_id
      end
    end
    
    #モデルの保存
    @match.save
    @opponent.save
    
    #更新した旨を通知
    broadcast(@match.user_id)
    
    #フラッシュメッセージの表示
    flash[:info] = msg
    
    #リダイレクト
    redirect_to matchs_path
    
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
    
    # 退出の旨をチャット参加者に配信
    broadcast(@match.user_id)
    
    #インスタンスを削除する
    @match.destroy
    flash[:info] = "対局室から退室しました"
    
    redirect_to root_path
  end
  
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
        a = user1
        b = user2
      else
        a = user2
        b = user1
      end
      return a, b
    end
   
    def broadcast(id)
     
      # チャット参加者に配信
      ActionCable.server.broadcast('match_channel', user_id: id)
    end
end
