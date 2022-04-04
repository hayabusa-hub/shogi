class Kaku < Koma
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #角
    move = {"-1": {"-1": 8, "1": 8},
            "1":  {"-1": 8, "1": 8}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.check_legal_pos(pos, turn)
    return true
  end
  
  def self.get_org_piece
    return KAKU
  end
  
  def self.get_promote_piece
    return UMA
  end
  
  def self.get_own_piece_num(turn, own_piece)
    _get_own_piece_num(KAKU, turn, own_piece)
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    _set_own_piece_num(KAKU, turn, num, own_piece)
  end
end