class Narikei < Keima
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #成桂
    move = {"-1": {"-1": 1, "0": 1, "1": 1},
            "0":  {"-1": 1, "1": 1},
            "1":  {"0": 1}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.judge_promote(before_pos, after_pos, turn)
    return false
  end
end