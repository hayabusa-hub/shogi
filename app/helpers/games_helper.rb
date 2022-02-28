module GamesHelper
  
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
  
  def is_reverse?(display)
    if(display == @first)
      false
    elsif(display == @second)
      true
    else
      nil
    end
  end
  
  def get_link_path(edit, pos)
    if edit == true
      #game_path(@game, before: params[:before], after: pos)
      "/games/#{@game.id}/putProcess?before=#{params[:before]}&amp;after=#{pos}"
    else
      edit_game_path(@game, before: pos)
    end
  end
  
  def getParams(before, after, promote, pos)
    if -1 == before
      before = pos
    elsif -1 == after
      after = pos
    end
    return before, after, promote
  end
  
  def getPosition(turn, piece)
    return 100*turn + piece.to_i
  end
end
