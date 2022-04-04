class Koma
  
  include GamesHelper
  
  def self.GetPiece(piece)
    case piece
    when FU then
      Fu
    when KYOUSYA then
      Kyousya
    when KEIMA then
      Keima
    when GIN then
      Gin
    when KIN then
      Kin
    when GYOKU then
      Gyoku
    when KAKU then
      Kaku
    when HISYA then
      Hisya
    when TOKIN then
      Tokin
    when NARIKYOU then
      Narikyou
    when NARIKEI then
      Narikei
    when NARIGIN then
      Narigin
    when UMA then
      Uma
    when RYUU then
      Ryuu
    end
  end
  
  def self.canMove?(before_pos, after_pos, turn, board, turn_board)
    return false
  end
  
  def self.check_legal_pos(pos, turn)
    # 継承して使用する(歩、香車、桂馬)
    return true
  end
  
  def self.judge_promote(before_pos, after_pos, turn)
    ret = false
    if false == check_legal_pos(after_pos, turn)
    elsif judge_promote_locate(before_pos, turn)
      ret = true
    elsif (0 <= before_pos && before_pos<= 80)
      if judge_promote_locate(after_pos, turn)
        ret = true
      end
    else
    end
    return ret
  end
  
  def self.get_org_piece
    return false
  end
  
  def self.get_promote_piece
    return false
  end
  
  def self.get_own_piece_num(turn, own_piece)
    return 0
  end
  
  def self.set_own_piece(num, turn, own_piece)
    have = get_own_piece_num(turn, own_piece)
    if(have+num >= 0 && get_org_piece > 0)
      ret = set_own_piece_num(turn, have+num, own_piece)
    else
      ret = false
    end
    return ret
  end
  
  def self.set_own_piece_num(turn, num, own_piece)
    return false
  end
  
  private
    
    def self.opp_1_row(turn)
      return (turn - 1) << 3
    end
    
    def self.opp_2_row(turn)
      return (turn << turn) - 1
    end
    
    def self.opp_3_row(turn)
      return (turn << 2) - 2
    end
    
    def self.judge_promote_locate(pos, turn)
      ret = true
      row = pos / 9
      
      if row == opp_1_row(turn)
      elsif row == opp_2_row(turn)
      elsif row == opp_3_row(turn)
      else
        ret = false
      end
      return ret
    end
    
    def self._canMove?(move, before_pos, after_pos, turn, board, turn_board)
    
      canMove = false
      
      before_row = before_pos / 9
      before_col = before_pos % 9
      
      after_row  = after_pos / 9
      after_col  = after_pos % 9
      
      if(0 <= before_pos and before_pos <= 80)
        
        move.each do |r_, tmp|
        
          r_ = r_.to_s.to_i
          if(turn == 2)
            r_ *= -1
          end
        
          tmp.each do |c_, value|
            c_ = c_.to_s.to_i
  
            for i in 1..value do
            
              #現在位置を取得
              pos = (before_row + i*r_) * 9 + (before_col + i*c_)
            
              #一致したとき
              if(after_row == before_row + i*r_) and (after_col == before_col + i*c_)
                canMove = true
                break
              end
              
              #途中で駒が存在したらループを抜ける
              if(board[pos] != "0")
                break
              end
            end
          end
        end
      else
        #歩、香車、桂馬は移動できない段でないことを確認する
        if check_legal_pos(after_pos)
          canMove = true
        end
        
        #2歩でないことを確認する
        # if "1" == piece and judge_two_fu(turn, after_pos)
        #   isLegal = false
        # end
      end
      
      return canMove
    end
    
    def self._get_own_piece_num(piece, turn, own_piece)
      num = own_piece[piece.to_i * 3 + turn]
      numPiece = {"0":0, "1":1,  "2":2,  "3":3,  "4":4,  "5":5,  "6":6,  "7":7,  "8":8,
                  "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15, "g":16, "h":17, "i":18 }
      if(numPiece[num.to_sym])
        numPiece[num.to_sym]
      else
        -1
      end
    end
    
    def self._set_own_piece_num(piece, turn, num, own_piece)
      numPiece = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i"]
      own_piece[piece.to_i * 3 + turn] = numPiece[num]
      return own_piece
    end
end