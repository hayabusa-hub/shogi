module GamesHelper
  
  FIRST = 1
  SECOND = 2
  X = ["9", "8", "7", "6", "5", "4", "3", "2", "1"]
  Y = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
  ORDER= [0, 1, 2, 3, 4, 5, 6, 7, 8]
  
  STANDBY = 0 #対戦待ち
  WAITING = 1 #対戦要求中
  DECLINE = 2
  PLAYING = 3 #ゲーム中
  
  #駒
  NOTHING  = ""
  FU       = "1"
  KYOUSYA  = "2"
  KEIMA    = "3"
  GIN      = "4"
  KIN      = "5"
  GYOKU    = "6"
  KAKU     = "7"
  HISYA    = "8"
  TOKIN    = "9"
  NARIKYOU = "a"
  NARIKEI  = "b"
  NARIGIN  = "c"
  UMA      = "e"
  RYUU     = "f"
  
  def get_image_path(piece, turn)
    image_path = ""
    if nil != piece
      image_path = "/shogi/"
      if (turn != @display) && (turn != 0)
        image_path += "opp_"
      end
      image_path += piece.to_s + ".png"
    end
    
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
    if(display == FIRST)
      false
    elsif(display == SECOND)
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
