class Game < ApplicationRecord
  
  def board_init(first, second)
    self.first_user_id = first
    self.second_user_id = second
    self.turn = 1
    self.board      = "234565432" + 
                      "080000070" + 
                      "111111111" + 
                      "000000000" + 
                      "000000000" +
                      "000000000" +
                      "111111111" +
                      "070000080" +
                      "234565432"
    self.turn_board = "222222222" +
                      "020000020" +
                      "222222222" +
                      "000000000" +
                      "000000000" +
                      "000000000" +
                      "111111111" +
                      "010000010" +
                      "111111111"
    self.own_piece  = "000" +
                      "100" +
                      "200" +
                      "300" +
                      "400" +
                      "500" +
                      "600" +
                      "700" +
                      "800"
    self.first_user_board = 0
    self.second_user_board = 0
    self.save
  end
  
  def set_board_display_mode(value, turn)
    # debugger
    if(turn == 1)
      self.first_user_board = value
    elsif(turn == 2)
      self.second_user_board = value
    else
      return false
    end
    
    if self.save
      return true
    else
      return false
    end
  end
  
  def legal?(piece, before_pos, after_pos)
    #対戦ユーザーかどうか確認する
    #手番が正しいか確認する
    #移動元の駒が自分の駒であるか確認する
    #移動先の場所に着手できるか確認する
    #飛び道具の場合はその間に駒がないか確認する
    isLegal = false
    
    pieceConvert = {"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8,
                    "9":5, "a":5, "b":5, "c":5, "e":9, "f":10 }
    
    move = []
    
    #歩
    move[1] = {"-1": {"0": 1}}
    
    #香車
    move[2] = {"-1": {"0": 8}}
    
    #桂馬
    move[3] = {"-2": {"-1": 1, "1": 1}}
    
    #銀
    move[4] = {"-1": {"-1": 1, "0": 1, "1": 1},
               "1":  {"-1": 1, "1": 1}}
    
    #金
    move[5] = {"-1": {"-1": 1, "0": 1, "1": 1},
               "0":  {"-1": 1, "1": 1},
               "1":  {"0": 1}}
    
    #玉
    move[6] = {"-1": {"-1": 1, "0": 1, "1": 1},
               "0":  {"-1": 1, "1": 1},
               "1":  {"-1": 1, "0": 1, "1": 1}}
    
    #角
    move[7] = {"-1": {"-1": 8, "1": 8},
               "1":  {"-1": 8, "1": 8}}
    
    #飛車
    move[8] = {"-1": {"0": 8},
               "0":  {"-1": 8, "1": 8},
               "1":  {"0": 8}}
               
    #馬
    move[9] = {"-1": {"-1": 8, "0": 1, "1": 8},
               "0":  {"-1": 1, "1": 1},
               "1":  {"-1": 8, "0": 1, "1": 8}}
    
    #龍
    move[10] = {"-1": {"-1": 1, "0": 8, "1": 1},
                "0":  {"-1": 8, "1": 8},
                "1":  {"-1": 1, "0": 8, "1": 1}}
    
    before_row = before_pos / 9
    before_col = before_pos % 9
    
    after_row  = after_pos / 9
    after_col  = after_pos % 9
    
    if(0 <= before_pos and before_pos <= 80)
      
      move[pieceConvert[piece.to_sym]].each do |r_, tmp|
      
        r_ = r_.to_s.to_i
        if(self.turn == 2)
          r_ *= -1
        end
      
        tmp.each do |c_, value|
          c_ = c_.to_s.to_i

          for i in 1..value do
          
            #現在位置を取得
            pos = (before_row + i*r_) * 9 + (before_col + i*c_)
          
            #一致したとき
            if(after_row == before_row + i*r_) and (after_col == before_col + i*c_)
              isLegal = true
              break
            end
          
            #途中で駒が存在したらループを抜ける
            if(self.board[pos].to_i != 0)
              break
            end
          end
        end
      end
    else
      
      #先手後手を区別しないといけない
      #歩、香車、桂馬は移動できない段でないことを確認する
      # if(piece == "1" and after_row == opp_1_row(self.turn))
      # elsif(piece == "2" and after_row == opp_1_row(self.turn))
      # elsif(piece == "3" and after_row == opp_1_row(self.turn))
      # elsif(piece == "3" and after_row == opp_2_row(self.turn))
      # #駒が存在していないことを確認する
      # elsif(self.turn_board[after_pos].to_i == 0)
      #   isLegal = true
      # end
      
      if check_legal_pos(piece, after_pos) and (self.turn_board[after_pos].to_i == 0)
        isLegal = true
      end
      
    end
    
    return isLegal
  end
  
  def put_piece?(user_turn, piece, before_pos, after_pos, is_promote)
    
    #ユーザーが正しいかどうか確認する
    # unless current_user
    #self.errors.add(:name, '文字数オーバー')
    #return
    
    #手番が正しいか確認する
    # if user_turn != self.turn
    #   self.errors.add(:name, 'あなたの手番ではありません')
    #   return false
    # end
    
    #移動元に、自分の指定駒が存在するか確認する
    if(0 <= before_pos and before_pos <= 80)
      #移動元が盤面上の駒の場合
      
      #駒が正しいか
      if self.board[before_pos] != piece
        self.errors.add(:name, '不正な駒です')
        return false
      end
      #自分の駒かどうか
      if self.turn_board[before_pos].to_i != self.turn
        self.errors.add(:name, 'それはあなたの駒ではありません')
        return false
      end
      
      #移動先に自分の駒がないかどうか
      if self.turn_board[after_pos].to_i == self.turn
        self.errors.add(:name, "#{after_pos}:自分の駒が存在するため、そこには着手できません")
        return false
      end
    elsif (before_pos >= 100)
      #移動元が持ち駒の場合
      
      #piece = before_pos % 100
      turn = before_pos / 100
      
      #相手の持ち駒を選択した場合
      if turn != self.turn
        self.errors.add(:name, 'それはあなたの持ち駒ではありません')
        return false
      end
      #持ち駒の数が1以上か
      if 0 >= get_own_piece_num(piece, self.turn)
        self.errors.add(:name, '持ち駒の数が不正です')
        return false
      end
    else
      self.errors.add(:name, '不正な盤情報が送信されました')
      return false
    end

    #着手が合法か確認する
    unless self.legal?(piece, before_pos, after_pos)
      self.errors.add(:name, 'その場所に移動することはできません')
      return false
    end
    
    #着手を行う
    before_put_piece(piece, before_pos)
    after_put_piece(piece, after_pos, is_promote)
    
    #手番を交代する
    self.turn ^= 3
    
    if self.save
      return true
    else
      self.errors.add(:name, '着手に失敗しました')
      return false
    end
  end
  
  def check_legal_pos(piece, pos)
    row = pos / 9
    ret = false
    if(piece == "1" and row == opp_1_row(self.turn))
    elsif(piece == "2" and row == opp_1_row(self.turn))
    elsif(piece == "3" and row == opp_1_row(self.turn))
    elsif(piece == "3" and row == opp_2_row(self.turn))
    else
      ret = true
    end
    return ret
  end
  
  def judge_promote(piece, before_pos, after_pos)
    ret = false
    if false == check_legal_pos(piece, after_pos)
    elsif judge_promote_locate(piece, before_pos, self.turn)
      ret = true
    elsif (0 <= before_pos && before_pos<= 80)
      if judge_promote_locate(piece, after_pos, self.turn)
        ret = true
      end
    else
    end
    return ret
  end
  
  def get_org_piece(piece)
    pieceConvert = {"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8,
                    "9":1, "a":2, "b":3, "c":4, "e":7, "f":8 }
    if(pieceConvert[piece.to_sym])
      pieceConvert[piece.to_sym]
    else
      -1
    end
  end
  
  def get_promote_piece(piece)
    if "1" == piece
      "9"
    elsif "2" == piece
      "a"
    elsif "3" == piece
      "b"
    elsif "4" == piece
      "c"
    elsif "7" == piece
      "e"
    elsif "8" == piece
      "f"
    else
      piece
    end
  end
  
  def get_own_piece_num(piece, turn)
    num = self.own_piece[get_org_piece(piece) * 3 + turn]
    numPiece = {"0":0, "1":1,  "2":2,  "3":3,  "4":4,  "5":5,  "6":6,  "7":7,  "8":8,
                "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15, "g":16, "h":17, "i":18 }
    if(numPiece[num.to_sym])
      numPiece[num.to_sym]
    else
      -1
    end
  end
  
  private
    def set_own_piece(piece, num)
      ret = true
      have = get_own_piece_num(piece, self.turn)
      if(have+num >= 0 && get_org_piece(piece) > 0)
        set_own_piece_num(piece, self.turn, have+num)
      else
        ret = false
      end
      return ret
    end
    
    def set_own_piece_num(piece, turn, num)
      numPiece = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i"]
      self.own_piece[get_org_piece(piece) * 3 + turn] = numPiece[num]
    end
    
    def before_put_piece(piece, pos)
      
      if(0 <= pos and pos <= 80)
        #盤面から着手した場合
        self.board[pos]      = 0.to_s
        self.turn_board[pos] = 0.to_s
      elsif(pos >= 100)
        #持ち駒から着手した場合
        set_own_piece(piece, -1)
      else
      end
      
    end
    
    def after_put_piece(piece, pos, is_promote)
      #移動先の駒
      opp_piece = self.board[pos]
      
      #移動先に相手の駒がある場合,持ち駒に追加する
      #上流ではじいているため、下の条件分岐は不要ではある
      if(self.turn_board[pos].to_i == self.turn^3)
        set_own_piece(opp_piece, 1)
      end
      
      #着手を行う
      if(true == is_promote) or (false == check_legal_pos(piece, pos))
        piece = get_promote_piece(piece)
      end
      self.board[pos]       = piece.to_s
      self.turn_board[pos]  = self.turn.to_s
    end
    
    def opp_1_row(turn)
      return (turn - 1) << 3
    end
    
    def opp_2_row(turn)
      return (turn << turn) - 1
    end
    
    def opp_3_row(turn)
      return (turn << 2) - 2
    end
    
    def judge_promote_locate(piece, pos, turn)
      ret = false
      row = pos / 9
      if piece != get_promote_piece(piece)
        if row == opp_1_row(turn)
          ret = true
        elsif row == opp_2_row(turn)
          ret = true
        elsif row == opp_3_row(turn)
          ret = true
        else
        end
      end
      return ret
    end
end
