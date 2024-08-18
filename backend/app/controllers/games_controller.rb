class GamesController < ApplicationController
  before_action :init, only: [:show, :edit, :update, :edit_board, :confirm, :update_board, :update_time, :resign, :updateBoard]
  
  include SessionsHelper
  include GamesHelper
  
  def init
    @user = current_user()
    @game = Game.find(params[:id])
    @my_turn = my_turn(@game)
    @display = display_mode(@game, @my_turn)
    @order = get_order(@display)
  end

  def show
    render json: outputType()
  end
  
  def edit_board
    # チェックボックスの値を取得する
    if FIRST == @my_turn
      mode = params[:game][:first_board].to_i
    elsif SECOND == @my_turn
      mode = params[:game][:second_board].to_i
    end
    
    set_board_display_mode(@game, mode, @my_turn)
    
    redirect_to game_path(@game)
  end
  
  # def confirm
  #   @before_pos = params[:before].to_i
  #   @after_pos  = params[:after].to_i
  # end
  
  # def update_board
  #   respond_to do |format|
  #     format.js
  #   end
  # end
  
  # def resign
  #   opp = User.find(@user.match.opponent_id)
  #   quit(@game, opp)
  # end
  
  # def disconnect
    
  #   flag = true
  #   @game = Game.find(params[:id])
  #   @user = current_user()
  #   @opp_match = Match.find_by(user_id: @user.match.opponent_id)
    
  #   #10秒間相手の接続が回復しない場合は接続切れとする
  #   start_time = Time.now
  #   while(Time.now - start_time <= 10) do
  #     @opp_match.reload
  #     if(PLAYING == @opp_match.status)
  #       flag = false
  #       break
  #     end
  #   end
    
  #   5.times {puts "********* disconnect: #{flag} ***********"} #debug用
  #   5.times {puts "********* pass time: #{Time.now - start_time} ***********"} #debug用
    
  #   #接続が回復しない場合は、接続切れ処理を行う
  #   if(flag)
  #     quit(@game, @user)
  #   end
  # end
  
  def quit
    # if(winner.name == game.first_user_name)
    #   game.winner = FIRST
    # elsif(winner.name == game.second_user_name)
    #   game.winner = SECOND
    # else
    #   #ここにはこない
    #   5.times {puts "********* User name is not correct ***********"}
    # end
    @game.winner = @my_turn^3
    @game.save
    
    # #盤面を更新
    # respond_to do |format|
    #   format.html { redirect_to game_path(@game.id)}
    #   format.js { render 'games/update_board.js.erb'}
    # end
  end
  
  def update_time
    
    #対戦相手が接続切れの場合
    if(@my_turn^3 == @game.connect)
      
      #接続切れ時間の更新
      @game.disconnect_time += 1
      @game.save
      
      #接続切れ処理を行う
      if @game.disconnect_time >= DISCONNECT_TIME
        quit(@game, @user)
      end
      
    else
      
      time = 1
      if(@game.turn == @my_turn) and (0 == @game.winner)
        
        #持ち時間を更新する(１秒減らす)
        if @my_turn == FIRST
          @game.first_have_time -= 1
          time = @game.first_have_time
        elsif @my_turn == SECOND
          @game.second_have_time -= 1
          time = @game.second_have_time
        else
          #ここにはこない
        end
      else
        #####################debug用#####################
        # 5.times {puts "********* 相手の手番です ***********"}
        #################################################
      end
      
      #更新
      @game.disconnect_time = 0
      @game.save
      
      #持ち時間が無くなった場合は、負けとする
      if time <= 0
        opp = User.find(@user.match.opponent_id)
        quit(@game, opp)
      elsif 0 == @game.winner
        
        #ゲームが続いている場合は残り時間のみを更新する
        respond_to do |format|
          format.js { render 'games/update_time.js.erb'}
        end
      else
        #ゲームが終了した場合は、ページ全体を更新する
        respond_to do |format|
          format.js { render 'games/update_board.js.erb'}
        end
      end
    end
    # if(@game.turn == @my_turn)
      
    #   #持ち時間を更新する(１秒減らす)
    #   if @my_turn == FIRST
    #     @game.first_have_time -= 1
    #     time = @game.first_have_time
    #   elsif @my_turn == SECOND
    #     @game.second_have_time -= 1
    #     time = @game.second_have_time
    #   else
    #     #ここにはこない
    #   end
      
    #   #保存
    #   @game.save
      
    #   #####################debug用#####################
    #   5.times {puts "********* Left time: #{time} ***********"}
    #   #################################################
    # else
    #   time = 1 #自分の手番でないときも残り時間を更新したいため
    # end
    
    # #持ち時間が無くなった場合は、負けとする
    # if time <= 0
    #   opp = User.find(@user.match.opponent_id)
    #   quit(@game, opp)
    # elsif 0 == @game.winner
      
    #   #ゲームが続いている場合は残り時間のみを更新する
    #   respond_to do |format|
    #     format.js { render 'games/update_time.js.erb'}
    #   end
    # else
    #   #ゲームが終了した場合は、ページ全体を更新する
    #   respond_to do |format|
    #     format.js { render 'games/update_board.js.erb'}
    #   end
    # end
    
  end

  def updateBoard
    @before_pos = params[:before_pos].to_i
    @after_pos = params[:after_pos].to_i
    @piece = get_piece(@game, @before_pos)
    @is_promote = params[:promote_flg]
    @is_select = params[:select_flg]
    confirmFlg = false
    
    if @game.legal?(@piece, @before_pos, @after_pos) and 
      (!@is_select) and 
      (@game.judge_promote(@piece, @before_pos, @after_pos))

      confirmFlg = true
    else
      if @game.put_piece?(@my_turn, @piece, @before_pos, @after_pos, @is_promote)
        #braodcastにより、盤面更新を通知する
        gameBroadcast(@game.id)
      else  
        # flash.now[:danger] = @game.errors.messages[:name][0]
        errMsg = @game.errors.messages[:name][0]
      end
    end

    render json: outputType(errMsg, confirmFlg, @piece)
  end
  
  private
    
    def display_mode(game, turn)
      if(@my_turn == FIRST)
        @game.first_user_board.to_i + 1
      elsif(@my_turn = SECOND)
        (@game.second_user_board.to_i + 1) % 2 + 1
      else
        nil
      end
    end
    
    def get_order(display)
      if(display == FIRST)
        ORDER
      elsif(display == SECOND)
        ORDER.reverse
      else
        nil
      end
    end
    
    def set_board_display_mode(game, value, turn)
      ret = true
      if(turn == FIRST)
        game.first_user_board = value
      elsif(turn == SECOND)
        game.second_user_board = value
      else
        ret = false
      end
      
      unless game.save
        ret = false
      end
      
      return ret
    end
    
    def get_piece(game, pos)
      if(0 <= pos and pos <= 80)
        game.board[pos]
      elsif(pos >= 100)
        (pos % 100).to_s
      else
        nil
      end
    end
    
    def get_turn(game, pos)
      if(0 <= pos and pos <= 80)
        game.turn_board[pos].to_i
      elsif(pos >= 100)
        (pos / 100)
      else
        nil
      end
    end
    
    def checkPromote(piece, before, after)
      return false
    end

    def get_own_piece_list(turn)
      ret = [0] * 9

      for piece in 1..8 do
        ret[piece] = @game.get_own_piece_num(piece.to_s, turn)
      end

      return ret
    end
    
    def outputType(errMsg="", confirmFlg=false, piece="")
      ret = {
        frontUserName: getUserInfo(@display, @game),
        backUserName: getUserInfo(@display^3, @game),
        row: Y,
        col: X,
        order: @order,
        display: @display,
        myTurn: @my_turn,

        board: @game.board,
        turnBoard: @game.turn_board,
        latestPos: @game.latest_place,
        frontOwnPieceList: get_own_piece_list(@display),
        backOwnPieceList: get_own_piece_list(@display^3),
        confirmFlg: confirmFlg,
        winner: @game.winner,

        orgPiece: piece,
        proPiece: @game.get_promote_piece(piece),
        
        errMsg:     errMsg
      }
    end 
end
