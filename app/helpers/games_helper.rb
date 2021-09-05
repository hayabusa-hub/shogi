module GamesHelper
  
  # def get_image_path(game, pos, opp)
  #   image_path = "/shogi/"
  #   if(@game.turn_board[pos].to_i == opp)
  #     image_path += "opp_"
  #   end
  #   image_path += @game.board[pos] + ".png"
  #   return image_path
  # end
  
  def get_image_path(piece, turn)
    image_path = "/shogi/"
    if (turn != @display) && (turn != 0)
      image_path += "opp_"
    end
    image_path += piece.to_s + ".png"
    return image_path
  end
  
  def get_own_piece(own_piece, turn)
    hash = {}
    9.times do |i|
      piece = own_piece[i*3].to_i
      num   = own_piece[i*3+turn].to_i
      hash[piece] = num
    end
    return hash
  end
  
  def board_reverse(game, display)
    if(display == @second)
      # @game.board.reverse!
      # @game.turn_board.reverse!
      # @X.reverse!
      # @Y.reverse!
    end
  end
  
  def is_reverse?(display)
    if(display == @first)
      false
    elsif(display == @second)
      true
    else
      nil
    end
  end
end
