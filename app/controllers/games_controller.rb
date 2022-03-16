class GamesController < ApplicationController
  before_action :init, only: [:show, :edit, :update, :edit_board, :confirm, :update_board]
  
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
    if @game.winner != 0
      render("/games/finish")
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
    5.times {puts "********* params    : #{params} ***********"}
    5.times {puts "********* before_pos: #{@before_pos} ***********"}
    5.times {puts "********* after_pos : #{@after_pos} ***********"}
    
    if -1 == @after_pos
      #ターンが正しいか確認する
      # if 
      
      #選んだ箇所を着色する
      respond_to do |format|
        format.html
        format.js   { render 'games/select.js.erb'}
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
          #ActionCable.server.broadcast("game_channel", game_id: @game.id)
          GameBroadCastJob.perform_later(@game)
          5.times {puts "********* put piece ***********"} #debug用
          
          #盤面情報を更新する
          #respond_to do |format|
            #format.html { redirect_to @game}
            #format.js   { render 'games/update_board.js.erb'}
            #format.js   { render 'games/speak.js.erb'}
          #end
        else
          flash[:danger] = @game.errors.messages[:name][0]
          
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
    if(@my_turn == FIRST)
      mode = params[:game][:first_board].to_i
    elsif(@my_turn == SECOND)
      mode = params[:game][:second_board].to_i
    else
    end
    
    @game = Game.find(params[:id])
    set_board_display_mode(@game, mode, @my_turn)
    
    if @game.save
      redirect_to game_path(@game)
    end
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
  
  private
    def my_turn(game)
      if(game.first_user_id == current_user.id)
        FIRST
      elsif(game.second_user_id == current_user.id)
        SECOND
      else
        nil
      end
    end
    
    def display_mode(game, turn)
      if(@my_turn == FIRST)
        @game.first_user_board.to_i + 1
      elsif(@my_turn = SECOND)
        @game.second_user_board.to_i + 1
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
      if(turn == FIRST)
        game.first_user_board = value
      elsif(turn == SECOND)
        game.second_user_board = value
      else
        return false
      end
      return true
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
