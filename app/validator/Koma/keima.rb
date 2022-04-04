class Keima < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #桂馬
    move = {"-2": {"-1": 1, "1": 1}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.check_legal_pos(pos, turn)
    row = pos / 9
    if(row == opp_1_row(turn)) or (row == opp_2_row(turn))
      ret = false
    else
      ret = true
    end
    return ret
  end
  
  def self.get_org_piece
    return KEIMA
  end
  
  def self.get_promote_piece
    return NARIKEI
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(KEIMA, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(KEIMA, turn, num, own_piece)
  end
end