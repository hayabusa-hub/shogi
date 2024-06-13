class Uma < Kaku
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #馬
    move = {"-1": {"-1": 8, "0": 1, "1": 8},
            "0":  {"-1": 1, "1": 1},
            "1":  {"-1": 8, "0": 1, "1": 8}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.judge_promote(before_pos, after_pos, turn)
    return false
  end
end