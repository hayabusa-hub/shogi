module GamesHelper
  
  FIRST = 1
  SECOND = 2
  DRAW = 3
  
  #盤面
  X = ["9", "8", "7", "6", "5", "4", "3", "2", "1"]
  Y = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
  ORDER= [0, 1, 2, 3, 4, 5, 6, 7, 8]
  DISCONNECT_TIME = 60
  
  STANDBY    = 0 #対戦待ち
  WAITING    = 1 #対戦要求が出されている
  REQUEST    = 2 #対戦要求を出している
  DECLINE    = 3 #対戦要求を拒絶
  PLAYING    = 4 #ゲーム中
  # DISCONNECT = 5 #切断中
  
  #game.connect
  CONNECTED = 0
  FIRST_DISCONNECT = 1
  SECOND_DISCONNECT = 2
  
  #駒
  NOTHING  = "0"
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
  
  def is_reverse?(my_turn, display)
    if my_turn == display
      false
    else
      true
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
  
  def getUserInfo(display, game)
    if(FIRST == display)
      msg = "[先手]: #{game.first_user_name}"
    elsif(SECOND == display)
      msg = "[後手]: #{game.second_user_name}"
    else
      msg = ""
    end
    return msg
  end
  
  def getLeftTime(display, game)
    if(FIRST == display)
      time = desplayTime(game.first_have_time)
    elsif(SECOND == display)
      time = desplayTime(game.second_have_time)
    else
      time = ""
    end
    return time
  end
  
  def gameBroadcast(game_id)
    data = {}
    data[:game_id] = game_id
    data[:time]  = false
    ActionCable.server.broadcast("game_channel_#{game_id}", data: data)
  end
  
  def gameTimeBroadcast(game_id)
    data = {}
    data[:time]  = true
    ActionCable.server.broadcast("game_channel_#{game_id}", data: data)
  end
  
  def desplayTime(time)
    minites = "#{time / 60}".rjust(2, "0")
    seconds = "#{time % 60}".rjust(2, "0")
    return "#{minites}:#{seconds}"
  end
  
  def my_turn(game)
    if(game.first_user_name == current_user.name)
      FIRST
    elsif(game.second_user_name == current_user.name)
      SECOND
    else
      nil
    end
  end
  
  def isConnected(game, display)
    return display != (game.connect & display)
  end
end
