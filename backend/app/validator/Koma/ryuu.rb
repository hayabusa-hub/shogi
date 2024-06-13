class Ryuu < Hisya
  
  include GamesHelper
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    
    #龍
    move = {"-1": {"-1": 1, "0": 8, "1": 1},
            "0":  {"-1": 8, "1": 8},
            "1":  {"-1": 1, "0": 8, "1": 1}}
    
    ret = _canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
    return ret
  end
  
  def self.judge_promote(before_pos, after_pos, turn)
    return false
  end
end