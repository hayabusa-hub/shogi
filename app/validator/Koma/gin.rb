class Gin < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #銀
    move = {"-1": {"-1": 1, "0": 1, "1": 1},
            "1":  {"-1": 1, "1": 1}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.check_legal_pos(pos, turn)
    return true
  end
  
  def self.get_org_piece
    return GIN
  end
  
  def self.get_promote_piece
    return NARIGIN
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(GIN, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(GIN, turn, num, own_piece)
  end
end