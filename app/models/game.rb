class Game < ApplicationRecord
  
  #relationship
  has_many :match
  has_many :game_record
  
  # attr_accessor :board_hash
  # attr_accessor :first_oute_seq
  # attr_accessor :second_oute_seq
  
  include GamesHelper
  # include GameRecordsHelper
  
  # @board_hash = {}
  
  # def initialize(attributes = {})
  #   @board_hash = {}
  # end
  
  
  # def board_hash
  #   @board_hash
  # end
  
  # def board_hash(key, value)
  #   @board_hash[key] = value
  # end
  
  # def init_board_hash
  #   self.board_hash = {}
  #   self.update!(board_hash: self.board_hash)
  # end
  
  # def board_hash
  #   @board_hash
  # end
  
  def board_init(first, second)
    self.first_user_name = first
    self.second_user_name = second
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
    self.first_king_pos = 74
    self.second_king_pos = 4
    # self.first_oute_seq = false
    # self.second_oute_seq = false
    #self.board_hash = {}
    # init_board_hash
    self.first_have_time = 600
    self.second_have_time = 600
    self.save
    
    record = self.game_record.new(cnt: 0, board: create_board_for_record())
    record.save()
  end
  
  def set_board_display_mode(value, turn)
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
  
  def legal?(piece, before_pos, after_pos, turn=self.turn, board=self.board, turn_board=self.turn_board)
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return false
    end
    
    # 各コマの移動が合法か確認する
    if false == pieceClass.canMove?(before_pos, after_pos, turn, board, turn_board)
      return false
    end
    
    return true
  end
  
  def put_piece?(user_turn, piece, before_pos, after_pos, is_promote)
    
    #ユーザーが正しいかどうか確認する
    # unless current_user
    #self.errors.add(:name, '文字数オーバー')
    #return
    
    #手番が正しいか確認する
    if user_turn != self.turn
      self.errors.add(:name, 'あなたの手番ではありません')
      return false
    end
    
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
        self.errors.add(:name, "自分の駒が存在するため、そこには着手できません")
        return false
      end
    elsif (before_pos >= 100)
      #移動元が持ち駒の場合
      
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
    
    #自玉に王手がかかっていないか確認する
    if is_oute_on_virtual?(piece, before_pos, after_pos, turn)
      self.errors.add(:name, '王手放置することはできません')
      return false
    end

    #着手が合法か確認する
    unless self.legal?(piece, before_pos, after_pos, self.turn)
      self.errors.add(:name, 'その場所に着手することはできません')
      return false
    end
    
    #着手を行う
    put_piece(piece, before_pos, after_pos, is_promote)
    
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
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return false
    end
    
    # コマの着手箇所が正しいか確認する
    ret = pieceClass.check_legal_pos(pos, turn)
    
    return ret
  end
  
  def judge_promote(piece, before_pos, after_pos)
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return false
    end
    
    # 成判定を行う
    ret = pieceClass.judge_promote(before_pos, after_pos, self.turn)
    
    return ret
  end
  
  def get_org_piece(piece)
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return false
    end
    
    # 各コマの成駒を取得する
    ret = pieceClass.get_org_piece
    
    return ret
  end
  
  def get_promote_piece(piece)
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return nil
    end
    
    # 各コマの元駒を取得する
    ret = pieceClass.get_promote_piece
    
    return ret
  end
  
  def get_own_piece_num(piece, turn, own_piece=self.own_piece)
    
    # 各コマのクラスを取得する
    pieceClass = Koma.GetPiece(piece)
    if nil == pieceClass
      return 0
    end
    
    # 持ち駒の数を取得する
    ret = pieceClass.get_own_piece_num(turn, own_piece)
    
    return ret
  end
  
  def get_king_pos(turn, board, turn_board)
    
    ret = -1
    
    for pos in 0..board.length do
      if ("6" == board[pos]) and (turn == turn_board[pos].to_i)
        ret = pos.to_i
      end
    end
    
    return ret
  end
  
  def is_checkmate?(turn = self.turn^3)
    
    is_checkmate = true
    
    #王手がかかっているか
    is_checkmate &= is_oute?(turn)
    
    #合法手をすべて着手して王手が回避できるかどうか
    for j in 0..80 do
      for i in 0..80 do
        if (turn == self.turn_board[i].to_i) and (turn != self.turn_board[j].to_i)
          piece = self.board[i]
          
          unless is_oute_on_virtual?(piece, i, j, turn)
            is_checkmate = false
          end
        end
      end
    end
    
    #持ち駒をすべて着手する
    for piece in 1..8 do
      pos = getPosition(turn, piece)
      
      num = get_own_piece_num(piece.to_s, turn)
      
      if num > 0
        for j in 0..80 do
          
          unless is_oute_on_virtual?(piece.to_s, pos, j, turn)
            is_checkmate = false
          end
          
        end
      end
    end
    
    return is_checkmate
  end
  
  def is_oute_on_virtual?(piece, before_pos, after_pos, turn = self.turn)
    is_oute = false
    
    #盤面情報をコピー
    board      = self.board.dup
    turn_board = self.turn_board.dup
    
    if self.legal?(piece, before_pos, after_pos, turn)
            
      #仮想盤面へ着手
      if(0 <= before_pos and before_pos <= 80)
        before_put_piece(piece, before_pos, board, turn_board)
      end
      after_put_piece(piece, after_pos, false, turn, board, turn_board)
      
    end
    
    #王手がかかっているか確認する
    if is_oute?(turn, board, turn_board)
      is_oute = true
    end
    
    return is_oute
  end
  
  def is_oute?(turn = self.turn, board = self.board.dup, turn_board = self.turn_board)
    pos = get_king_pos(turn, board, turn_board)
    is_oute = false
    
    for i in 0..80 do
      if turn^3 == turn_board[i].to_i
        piece = board[i]
        
        if self.legal?(piece, i, pos, turn^3, board, turn_board)
          is_oute = true
        end
      end
    end
    return is_oute
  end
  
  private
    def set_own_piece(piece, num)
      
      # 各コマのクラスを取得する
      pieceClass = Koma.GetPiece(piece)
      if nil == pieceClass
       return
      end
      
      # 持ち駒を更新する
      pieceClass.set_own_piece(num, self.turn, self.own_piece)
    end
    
    def put_piece(piece, before_pos, after_pos, is_promote, board=self.board, turn_board=self.turn_board)
      
      ###移動元の盤面情報をリセット
      before_put_piece(piece, before_pos, board, turn_board)
      
      ###移動先の盤面情報を更新
      #移動先の駒
      opp_piece = board[after_pos]
      
      #移動先に相手の駒がある場合,持ち駒に追加する
      #上流ではじいているため、下の条件分岐は不要ではある
      if(turn_board[after_pos].to_i == self.turn^3)
        set_own_piece(opp_piece, 1)
      end
      
      #着手を行う
      after_put_piece(piece, after_pos, is_promote, self.turn, board, turn_board)
      
      #移動した駒が玉の場合、玉の位置を更新する
      if "6" == piece
        set_king_pos(after_pos, self.turn)
      end
      
      #着手盤面情報を更新
      self.second_latest_place = self.latest_place
      self.latest_place = after_pos
      
      # 手数を進め、game_recordへ保存
      self.move_cnt += 1
      record = self.game_record.new(cnt: self.move_cnt, board: create_board_for_record(), isOute: self.is_oute?() | self.is_oute?(self.turn^3))
      record.save()
      
      #詰んでいる場合
      if self.is_checkmate?()
        self.winner = self.turn
        return
      end
      
      #千日手の場合
      isSeq, isSeqOute = check_repetition()
      if isSeqOute
        self.winner = self.turn^3
      elsif isSeq
        self.winner = DRAW
      else
        #何もしない
      end
    end
    
    def before_put_piece(piece, pos, board=self.board, turn_board=self.board)
      
      if(0 <= pos and pos <= 80)
        #盤面から着手した場合
        board[pos]      = 0.to_s
        turn_board[pos] = 0.to_s
      elsif(pos >= 100)
        #持ち駒から着手した場合
        set_own_piece(piece, -1)
      else
      end
      
    end
    
    def after_put_piece(piece, pos, is_promote, turn=self.turn, board=self.board, turn_board=self.board)
      
      #着手を行う
      if(true == is_promote) or (false == check_legal_pos(piece, pos))
        piece = get_promote_piece(piece)
      end
      board[pos]       = piece.to_s
      turn_board[pos]  = turn.to_s
    end
    
    def set_king_pos(pos, turn)
      if 1 == turn
        self.first_king_pos = pos
      elsif 2 == turn
        self.second_king_pos = pos
      else
        nil
      end
    end
    
    # def set_board_hash(turn=self.turn, board=self.board, turn_board=self.board, own_piece=self.own_piece)
    #   key = (board + turn_board + own_piece).to_sym
      
    #   ########################
    #   if nil == self.board_hash
    #     #debugger
    #   end
    #   ########################
    #   if nil == @board_hash[key]
    #     @board_hash[key] = 1
    #   else
    #     @board_hash[key] += 1
        
    #     value = is_oute?(turn^3)
    #     if 2 == @board_hash[key]
    #       set_seq_status(turn, value)
    #     else
    #       value &= get_seq_status(turn)
    #       set_seq_status(turn, value)
    #     end
    #   end
    # end
    
    # def set_seq_status(turn, value)
    #   if 1 == turn
    #     self.first_oute_seq = value
    #   elsif 2 == turn
    #     self.second_oute_seq = value
    #   else
    #   end
    # end
    
    # def get_seq_status(turn)
    #   if 1 == turn
    #     self.first_oute_seq
    #   elsif 2 == turn
    #     self.second_oute_seq
    #   else
    #     #debugger
    #   end
    # end
    
    def check_repetition()
      hash = {}
      board = create_board_for_record()
      isSeq = true
      isSeqOute = true
      
      records = self.game_record.order(cnt: "DESC")
      
      # 同一局面の数を数える
      records.each do |record|
        if nil == hash[record.board]
          hash[record.board] = 1
        else
          hash[record.board] += 1
        end
        
        #　連続王手かどうか
        if (get_turn(record.cnt) == self.turn) && (1 == hash[board])
          isSeqOute &= record.isOute
        end
      end
      
      # 同一局面の数が4回以上出現したとき、千日手とする
      if 4 > hash[board]
        isSeq = false
        isSeqOute = false
      end
      
      return isSeq, isSeqOute
    end
    
    def create_board_for_record()
      return self.board + self.turn_board + self.own_piece
    end
    
    def get_turn(cnt)
      # 奇数→1　偶数→2
      return (cnt - 1) % 2 + 1
    end
end
