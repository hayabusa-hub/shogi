class Kyousya < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #香車
    move = {"-1": {"0": 8}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
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
    return KYOUSYA
  end
  
  def self.get_promote_piece
    return NARIKYOU
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(KYOUSYA, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(KYOUSYA, turn, num, own_piece)
  end
end