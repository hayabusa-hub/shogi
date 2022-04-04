class Fu < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #歩
    move = {"-1": {"0": 1}}
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board) 
    
    # 持ち駒から着手する場合、2歩の確認をする
    if (before_pos >= 100) && (judge_two_fu(turn, after_pos, board, turn_board))
      ret = false
    end
    
    return ret
  end
  
  def self.check_legal_pos(pos, turn)
    row = pos / 9
    if(row == opp_1_row(turn))
      ret = false
    else
      ret = true
    end
    return ret
  end
  
  def self.get_org_piece
    return FU
  end
  
  def self.get_promote_piece
    return TOKIN
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(FU, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(FU, turn, num, own_piece)
  end
  
  private
    def self.judge_two_fu(turn, position, board, turn_board)
      ret = false
      col = position % 9
        
      for i in 0..8 do
        pos = i * 9 + col
        if (turn == turn_board[pos].to_i) and (FU == board[pos])
          ret = true
          break
        end
      end
      return ret
    end
end