class GamesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    first, second = make_turn(params[:user1], params[:user2])
    @game = Game.new()
    @game.first_user_id = first
    @game.second_user_id = second
    @game.board = init_board()
    
    if @game.save
      debugger
      redirect_to game_path(@game)
    else
      flash[:danger] = "error has occurred"
      redirect_to matchs_path
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
  private
    def make_turn(user1, user2)
      tmp = rand(1)
      if(tmp == 0)
        a = user1
        b = user2
      else
        a = user2
        b = suer1
      end
      return a, b
    end
    
    def init_board
      ret = "234565432" + 
            "080000070" + 
            "111111111" + 
            "000000000" + 
            "000000000" +
            "000000000" +
            "111111111" +
            "070000080" +
            "234565432"
      return ret
    end
    
end
