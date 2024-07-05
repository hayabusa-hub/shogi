class MatchsController < ApplicationController
  
  include SessionsHelper
  include GamesHelper
  
  before_action :init
  # before_action :update_user_list, only: [:update_info, :request_match, :accept_match, :decline_match]
  
  # loginユーザーとparams[:id]が一致しているかチェックする
  def init
    @user = current_user()
    @opponent = Match.find_by(opponent_id: @user.id)
    @match = Match.find_by(user_id: @user.id)
    @matches = User.joins(
      "inner join matches 
         on matches.user_id = users.id 
       where 
         matches.status = #{STANDBY}
         and matches.user_id <> #{@user.id}"
    )
  end
  
  def getRoomInfo
    render json: outputType()
  end

  def enter_room
    
    @match = Match.new(user_id: @user.id)
    if @match.save
      # 入室の旨をチャット参加者に配信
      broadcast(@match.user_id)
      # puts "対局室へ移動しました"
    elsif @match = Match.find_by(user_id: @user.id)
      # puts "すでに対局室へいます"
    else
      errMsg = "対局室への移動へ失敗しました"
      raise errMsg
    end

    render json: outputType(errMsg)
  end

  def leave_room
    if @opponent
      @opponent.status = STANDBY
      @opponent.opponent_id = 0
    end

    if @match.destroy && (!@opponent || @opponent.save)
      # 退出の旨をチャット参加者に配信
      broadcast()
    else
      errMsg = "エラーが発生したため、退室に失敗しました"
      raise errMsg
    end
    render json: outputType(errMsg)
  end

  def make_request
    opp_id = params[:opp_id]
    @opponent = Match.find_by(user_id: opp_id)

    if(STANDBY == @opponent.status)
      opp = User.find_by(id: opp_id)
      if(STANDBY == @match.status)
        #状態を更新
        @match.opponent_id = opp_id
        @match.status = REQUEST
        @opponent.opponent_id = @match.user_id
        @opponent.status = WAITING
        if @match.save && @opponent.save
          broadcast(opp_id)
        else
          errMsg = "エラーが発生したため、対戦要求を出すことはできませんでした。"
        end
      elsif(REQUEST == @match.status)
        errMsg = "複数の対戦要求を出すことはできません"
      elsif(WAITING == @match.status)
        errMsg = "既に#{opp.name}から対戦要求が出されています"
      else
        # ここにはこない
        raise "不正な値です"
      end
    else
      errMsg = "別の人が対戦要求を出しています"
    end
    render json: outputType(errMsg)
  end

  def accept_request

    @opponent = Match.find_by(user_id: params[:opp_id])

    #状態を更新
    @match.opponent_id = @opponent.user_id
    @match.status = PLAYING
    @opponent.status = PLAYING
    
    #ゲームモデルを作成
    game_id = make_game(@match.user, @opponent.user)
    @match.game_id = game_id
    @opponent.game_id = game_id
    
    #保存
    if @match.save && @opponent.save
    
      msg = "対局開始！！！"
      broadcast(@opponent.user_id, true)
    else
      errMsg = "対局を開始できませんでした"
      raise errMsg
    end
    render json: outputType(errMsg)
  end

  def decline_request

    @opponent = Match.find_by(user_id: params[:opp_id])

    #状態を更新
    @match.status = STANDBY
    @match.opponent_id = 0
    @opponent.status = STANDBY
    @opponent.opponent_id = 0
    if @match.save && @opponent.save
      broadcast(@opponent.user_id)
    else
      errMsg = "エラーが発生したため、対戦要求をキャンセルできませんでした"
      raise errMsg
    end
    
    puts "対戦要求を拒否しました"
    render json: outputType(errMsg)
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

    def outputType(errMsg="")
      ret = {
        user:       @user,
        requestFlg: @match && @match.status ==  REQUEST ? true: false,
        waitingFlg: @match && @match.status ==  WAITING ? true: false,
        playingFlg: @match && @match.status ==  PLAYING ? true: false,
        opp:        @opponent ? @opponent.user : nil,
        userList:   @matches,
        errMsg:     errMsg
      }
    end 
end
