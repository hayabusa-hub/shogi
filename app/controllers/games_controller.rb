class GamesController < ApplicationController
  before_action :init, only: [:show, :edit, :update, :edit_board, :confirm, :update_board, :update_time]
  
  include SessionsHelper
  include GamesHelper
  
  def init
    @user = current_user()
    @game = Game.find(params[:id])
    @my_turn = my_turn(@game)
    @display = display_mode(@game, @my_turn)
    @order = get_order(@display)
  end
  
  def index
  end

  def show
    if @my_turn == @game.turn
      flash[:info] = "あなたの手番です"
    else
      flash[:info] = "相手の手番です"
    end
  end

  def new
  end

  def create
  end

  def edit
  end
  
  def update
    @before_pos = params[:game][:before].to_i
    @after_pos = params[:game][:after].to_i
    @piece = get_piece(@game, @before_pos)
    @is_promote = get_is_promote(params[:game][:promote])
    
    #debug用
    # 5.times {puts "********* params    : #{params} ***********"}
    # 5.times {puts "********* before_pos: #{@before_pos} ***********"}
    # 5.times {puts "********* after_pos : #{@after_pos} ***********"}
    
    if -1 == @after_pos
      #ターンが正しいか確認する
      # if 0 != get_turn(@game, @before_pos)#### debug用 #############
      if @my_turn == get_turn(@game, @before_pos)
        #選んだ箇所を着色する
        respond_to do |format|
          format.html
          format.js   { render 'games/select.js.erb'}
        end
      end
    else
      if @game.legal?(@piece, @before_pos, @after_pos) and 
        (nil == @is_promote) and 
        (@game.judge_promote(@piece, @before_pos, @after_pos))
        
        #成駒判定
        respond_to do |format|
          format.html
          format.js   { render 'games/confirm.js.erb'}
        end
        
        return
      else
        if(nil == @is_promote)
          @is_promote = false
        end
        
        if @game.put_piece?(@my_turn, @piece, @before_pos, @after_pos, @is_promote)
          
          #braodcastにより、盤面更新を通知する
          # ActionCable.server.broadcast("game_channel", game_id: @game.id)
          gameBroadcast(@game.id)
        else
          
          flash.now[:danger] = @game.errors.messages[:name][0]
          
          #選択を解除する
          respond_to do |format|
            format.html
            format.js   { render 'games/release.js.erb'}
          end
        end
      end
      
    end
  end

  def destroy
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
  
  def confirm
    @before_pos = params[:before].to_i
    @after_pos  = params[:after].to_i
  end
  
  def update_board
    respond_to do |format|
      format.js
    end
  end
  
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
  
  def quit(game, winner)
    if(winner.name == game.first_user_name)
      game.winner = FIRST
    elsif(winner.name == game.second_user_name)
      game.winner = SECOND
    else
      #ここにはこない
      5.times {puts "********* User name is not correct ***********"}
    end
    game.save
    
    #盤面を更新
    respond_to do |format|
      format.html { redirect_to game_path(game.id)}
      format.js { render 'games/update_board.js.erb'}
    end
  end
  
  def update_time
    
    @opp_match = Match.find_by(user_id: @user.match.opponent_id)
    
    #対戦相手が接続切れの場合
    if(DISCONNECT == @opp_match.status)
      
      #接続切れ時間の更新
      @game.disconnect_time += 1
      @game.save
      
      #接続切れ処理を行う
      if @game.disconnect_time >= DISCONNECT_TIME
        quit(@game, @user)
      end
      
    else
      @game.disconnect_time = 0
      
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
      end
      
      #保存
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
  
  private
    def my_turn(game)
      if(game.first_user_name == current_user.name)
        FIRST
      elsif(game.second_user_name == current_user.name)
        SECOND
      else
        nil
      end
    end
    
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
    
    def get_is_promote(str)
      if str == "true"
        true
      elsif str == "false"
        false
      else
        nil
      end
    end
end
