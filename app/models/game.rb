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
    
    # dx = [-1, 0, 1, -1, 0, 1, -1, 0, 1]
    # dy = [-1, -1, -1, 0, 0, 0, 1, 1, 1]
    
    # move = [ [0, 0, 0, 0, 0, 0, 0, 0, 0],
    #         [0, 1, 0, 0, 0, 0, 0, 0, 0], #歩
    #         [0, 2, 0, 0, 0, 0, 0, 0, 0], #香車
    #         [1, 0, 1, 0, 0, 0, 0, 0, 0], #桂馬
    #         [1, 1, 1, 0, 0, 0, 1, 0, 1], #銀
    #         [1, 1, 1, 1, 0, 1, 0, 1, 0], #金
    #         [1, 1, 1, 1, 0, 1, 1, 1, 1], #玉
    #         [2, 0, 2, 0, 0, 0, 2, 0, 2], #角
    #         [0, 2, 0, 2, 0, 2, 0, 2, 0]  #飛車
    #   ]
    
    # move = [ [],
    #         [[-1, 0, 1]],
    #         [[-1, 0, 8]],
    #         [[-2, -1, 1], [-2, 1, 1]],
    #         [[-1, -1, 1], [-1, 0, 1], ]
    #   ]
    
    move = Hash.new(Hash.new(Hash.new()))
    
    # #歩
    # move[1][-1][0] = 1
    
    # #香車
    # move[2][-1][0] = 8
    
    # #桂馬
    # move[3][-2][-1] = 1
    # move[3][-2][1]  = 1
    
    # #銀
    # for i in -1..1 do
    #   move[4][-1][i] = 1
    # end
    # move[4][1][-1] = 1
    # move[4][1][1] = 1
    
    # #金
    # for i in -1..1 do
    #   move[5][-1][i] = 1
    # end
    # move[5][0][-1] = 1
    # move[5][0][1]  = 1
    # move[5][1][0]  = 1
    
    # #玉
    # for i in -1..1 do
    #   move[6][-1][i] = 1
    #   move[6][1][i]  = 1
    # end
    # move[6][0][-1] = 1
    # move[6][0][1]  = 1
    
    # #角
    # move[7][-1][-1] = 8
    # move[7][-1][1]  = 8
    # move[7][1][-1]  = 8
    # move[7][1][1]   = 8
    
    # #飛車
    # move[8][-1][0] = 8
    # move[8][0][-1] = 8
    # move[8][0][1]  = 8
    # move[8][1][0]  = 8
    
    
    # move = [{},
    #         {"-1": {"0": 1}},
    #         {"-1": {"0": 8}}
    # ]
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
     
    
    before_row = before_pos / 9
    before_col = before_pos % 9
    
    after_row  = after_pos / 9
    after_col  = after_pos % 9
    
    # if(self.turn == 2)
    #   before_row *= -1
    #   after_row  *= -1
    # end
    
    row = (after_row - before_row).to_s.to_sym
    col = (after_col - before_col).to_s.to_sym
    
    # if(move[piece][row] != nil)
    #   if(move[piece][row][col] == 1)
    #     isLegal = true
    #   end
    # end
    
    move[piece].each do |r_, tmp|
      
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
    
    return isLegal
  end
  
  def put_piece?(user_turn, piece, before_pos, after_pos)
    
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
      if self.board[before_pos].to_i != piece
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
      #持ち駒の数が1以上か
      if 0 == self.own_piece[piece * 3 + self.turn].to_i
        self.errors.add(:name, 'それはあなたの持ち駒ではありません')
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
    
    #移動先に相手の駒がある場合,持ち駒に追加する
    # if self.turn_board[after_pos].to_i == (self.turn ^ 3)
    #   opp_piece = self.board[after_pos].to_i
    #   set_own_piece(opp_piece, 1)
      # have = self.own_piece[opp_piece * 3 + self.turn].to_i
      # self.own_piece[opp_piece * 3 + self.turn] = (have + 1).to_s
    # end
    
    #着手を行う
    before_put_piece(piece, before_pos)
    after_put_piece(piece, after_pos)
    # if(0 <= before_pos and before_pos <= 80)
    #   #移動元が盤面上の駒の場合
    #   before_put_piece(before_pos)
    #   # self.board[before_pos]      = 0.to_s
    #   # self.turn_board[before_pos] = 0.to_s
    #   after_put_piece(piece, after_pos)
    #   #self.board[after_pos]       = piece.to_s
    #   #self.turn_board[after_pos]  = self.turn.to_s
      
    # elsif (before_pos >= 100)
    #   #移動元が持ち駒の場合
    #   # have = self.own_piece[piece * 3 + self.turn].to_i
    #   # self.own_piece[piece * 3 + self.turn] = (have - 1).to_s
    #   set_own_piece(piece, -1)
    #   # self.board[after_pos]       = piece.to_s
    #   # self.turn_board[after_pos]  = self.turn.to_s
    #   after_put_piece(piece, after_pos)
    # else
    #   self.errors.add(:name, '不正な盤情報が送信されました')
    #   return false
    # end
    
    #手番を交代する
    self.turn ^= 3
    
    if self.save
      return true
    else
      self.errors.add(:name, '着手に失敗しました')
      return false
    end
  end
  
  private
    def set_own_piece(piece, num)
      ret = true
      have = self.own_piece[piece * 3 + self.turn].to_i
      if(have+num > 0 && piece > 0)
        self.own_piece[piece * 3 + self.turn] = (have + num).to_s
      else
        ret = false
      end
      return ret
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
    
    def after_put_piece(piece, pos)
      #移動先の駒
      opp_piece = self.board[pos].to_i
      
      #着手を行う
      self.board[pos]       = piece.to_s
      self.turn_board[pos]  = self.turn.to_s
      
      #移動先に相手の駒がある場合,持ち駒に追加する
      set_own_piece(opp_piece, 1)
    end
end
