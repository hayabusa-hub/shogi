class GamesController < ApplicationController
  before_action :init, only: [:show, :edit, :update, :edit_board, :confirm]
  
  include SessionsHelper
  
  def init
    @user = current_user()
    @game = Game.find(params[:id])
    
    @first = FIRST
    @second = SECOND
    @X = X
    @Y = Y
    
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
    # debugger
    # first, second = make_turn(params[:user1], params[:user2])
    # @game = Game.new()
    # @game.board_init(first, second)
    
    # if @game.save
    #   redirect_to game_path(@game)
    # else
    #   flash[:danger] = "error has occurred"
    #   redirect_to matchs_path
    # end
  end

  def edit
  end

  # def update
  #   before_pos = params[:before].to_i
  #   after_pos = params[:after].to_i
  #   piece = get_piece(@game, before_pos)
  #   is_promote = get_is_promote(params[:promote])
    
  #   unless @game.put_piece?(@my_turn, piece, before_pos, after_pos, is_promote)
  #     flash[:danger] = @game.errors.messages[:name][0]
  #   end
    
  #   #ゲーム画面へ移動する
  #   respond_to do |format|
  #     format.html { redirect_to @game }
  #     format.js
  #   end
  # end
  
  def update
    before_pos = params[:game][:before].to_i
    after_pos = params[:game][:after].to_i
    piece = get_piece(@game, before_pos)
    is_promote = get_is_promote(params[:game][:promote])
    if -1 == after_pos
      # respond_to do |format|
      #   format.html { redirect_to edit_game_path(@game, before: before_pos) }
      #   format.js
      # end
      
      #ターンが正しいか
      #
      redirect_to edit_game_path(@game, before: before_pos)
    else
      if @game.legal?(piece, before_pos, after_pos) and 
        (nil == is_promote) and 
        (@game.judge_promote(piece, before_pos, after_pos))
        
        #成駒判定
        redirect_to "/games/#{@game.id}/confirm?before=#{before_pos}&amp;after=#{after_pos}"
        return
      else
        if(nil == is_promote)
          is_promote = false
        end
        
        if @game.put_piece?(@my_turn, piece, before_pos, after_pos, is_promote)
          # respond_to do |format|
          #   format.html { redirect_to @game }
          #   format.js
          # end
          redirect_to @game 
        else
          flash[:danger] = @game.errors.messages[:name][0]
          redirect_to @game 
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
  
  private
    # def make_turn(user1, user2)
    #   tmp = rand(2)
    #   if(tmp == 0)
    #     a = user1
    #     b = user2
    #   else
    #     a = user2
    #     b = user1
    #   end
    #   return a, b
    # end
    
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
