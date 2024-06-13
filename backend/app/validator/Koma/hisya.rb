class Hisya < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #飛車
    move = {"-1": {"0": 8},
            "0":  {"-1": 8, "1": 8},
            "1":  {"0": 8}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.check_legal_pos(pos, turn)
    return true
  end
  
  def self.get_org_piece
    return HISYA
  end
  
  def self.get_promote_piece
    return RYUU
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(HISYA, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(HISYA, turn, num, own_piece)
  end
end