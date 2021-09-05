class Game < ApplicationRecord
  
  def board_init(first, second)
    self.first_user_id = first
    self.second_user_id = second
    self.turn = 1
    self.board      = "234565432" + 
                      "080000070" + 
                      "111111111" + 
                      "000000000" + 
                      "000000000" +
                      "000000000" +
                      "111111111" +
                      "070000080" +
                      "234565432"
    self.turn_board = "222222222" +
                      "020000020" +
                      "222222222" +
                      "000000000" +
                      "000000000" +
                      "000000000" +
                      "111111111" +
                      "010000010" +
                      "111111111"
    self.own_piece  = "000" +
                      "100" +
                      "200" +
                      "300" +
                      "400" +
                      "500" +
                      "600" +
                      "700" +
                      "800"
    self.first_user_board = 0
    self.second_user_board = 0
    self.save
  end
  
  def set_board_display_mode(value, turn)
    # debugger
    if(turn == 1)
      self.first_user_board = value
    elsif(turn == 2)
      self.second_user_board = value
    else
      return false
    end
    
    if self.save
      return true
    else
      return false
    end
  end
  
  def legal?(before_pos, after_pos)
    #対戦ユーザーかどうか確認する
    #手番が正しいか確認する
    #移動元の駒が自分の駒であるか確認する
    #移動先の場所に着手できるか確認する
    isLegal = true
    return isLegal
  end
  
  def put_piece?(before_pos, after_pos)
    
    #対戦ユーザーかどうか確認する
    # unless current_user
    
    #手番が正しいか確認する
    # unless self.turn_board[before_pos].to_i == self.turn
    #   return false
    # end

    #着手が合法か確認する
    unless self.legal?(before_pos, after_pos)
      return false
    end
    
    #移動先に相手の駒がある場合,持ち駒に追加する
    if self.turn_board[after_pos].to_i == (self.turn ^ 3)
      opp_piece = self.board[after_pos].to_i
      have = self.own_piece[opp_piece * 3 + self.turn].to_i
      self.own_piece[opp_piece * 3 + self.turn] = (have + 1).to_s
    end
    
    #着手を行う
    piece = self.board[before_pos]
    self.board[before_pos]      = 0.to_s
    self.turn_board[before_pos] = 0.to_s
    self.board[after_pos]       = piece
    self.turn_board[after_pos]  = self.turn.to_s
    
    #手番を交代する
    self.turn ^= 3
    
    if self.save
      return true
    else
      return false
    end
  end
  
  
end
