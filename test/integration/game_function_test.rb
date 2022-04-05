require 'test_helper'

class GameFunctionTest < ActionDispatch::IntegrationTest
  def setup
    @test1 = users(:test1)
    @test2 = users(:test2)
    @game = Game.new()
    @game.board_init(@test1.name, @test2.name)
    @game.save
    @match1 = Match.create(user_id: @test1, opponent_id: @test2, status: 3, game_id: @game)
    @match2 = Match.create(user_id: @test2, opponent_id: @test1, status: 3, game_id: @game)
    @test1.match = @match1
    @test2.match = @match2
    
    @FIRST = 1
    @SECOND = 2
    
    #テスト1としてログイン
    get login_path
    login_as(@test1)
    
    #ゲーム画面へ移動
    get game_path(@game)
  end
  
  def set_turn(turn)
    if 1 == turn
      @game.first_user_name = @test1.name
      @game.second_user_name = @test2.name
      @user = @test1
    elsif 2 == turn
      @game.first_user_name = @test2.name
      @game.second_user_name = @test1.name
      @user = @test2
    else
      return false
    end
    @game.turn = turn
    
    return @game.save
  end
  
  def ownPieceCount(piece, turn)
    numPiece = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i"]
      num = @game.own_piece[getOrgPiece(piece) * 3 + turn]
      19.times do |i|
        if(numPiece[i] == num)
          return i
        end
      end
      return -1
  end
  
  def setOwnPieceCount(piece, turn, num)
    numPiece = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i"]
    @game.own_piece[getOrgPiece(piece) * 3 + turn] = numPiece[num]
  end
  
  def getOrgPiece(piece)
    pieceConvert = {"0":0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8,
                    "9":1, "a":2, "b":3, "c":4, "e":7, "f":8 }
    if(pieceConvert[piece.to_sym])
      pieceConvert[piece.to_sym]
    else
      -1
    end
  end
  
  
  def show_board(board)
    for i in 0..8 do
      st = ""
      for j in 0..8 do
        st += board[i*9+j]
      end
      puts st
    end
  end
  
  def checkPutpieceTest_abnormal(array, before_pos, piece, turn, board, turn_board, own_piece=@game.own_piece)
    #ゲーム画面を更新
    @game.board = board
    @game.turn_board = turn_board
    @game.own_piece = own_piece
    #手番を強引に変更する
    set_turn(turn)
    
    @game.save
    for i in 0..80 do
      if(true == array.include?(i))
        next
      end
      flash[:danger] = nil
      
      #移動先の盤面情報を取得
      opp_piece = @game.board[i]
      num = ownPieceCount(opp_piece, turn)
      before_piece = @game.board[before_pos]
      
      #着手
      patch game_path(@game, game: {before: before_pos, after: i}), xhr: true
      
      if (0 <= before_pos) and (before_pos <= 80)
        assert @game.reload.board[before_pos] == before_piece
      end
      assert num == ownPieceCount(opp_piece, turn)
    end
  end
  
  def checkPutpieceTest(array, before_pos, piece, turn, board, turn_board, own_piece=@game.own_piece)
    
      for i in array do
        
        #ゲーム画面を更新
        @game.board = board
        @game.turn_board = turn_board
        @game.own_piece = own_piece
         #手番を強引に変更する
        set_turn(turn)
        @game.save
      
        #前回までのフラッシュを削除
        flash[:danger] = nil
        
        #移動先の盤面情報を取得
        opp_piece = @game.board[i]
        num = ownPieceCount(opp_piece, turn)
        
        # 着手
        patch game_path(@game, game: {before: before_pos, after: i, promote: false}), xhr: true
        # if(false == flash.empty?)
        #   debugger
        # end
        if(@game.reload.board[i] != piece.to_s)
          debugger
        end
        
        # 着手前の場所には
        #assert flash.empty?
        assert @game.reload.board[before_pos] == "0"
        assert @game.reload.turn_board[before_pos] == "0"
        assert @game.reload.board[i] == piece.to_s
        assert @game.reload.turn_board[i] == turn.to_s
        
        ###########################
        if("0" != opp_piece) && (num + 1 != ownPieceCount(opp_piece, turn))
          #debugger
        end
        ############################
        
        if("0" == opp_piece)
          assert num == ownPieceCount(opp_piece, turn)
        else
          assert num + 1 == ownPieceCount(opp_piece, turn)
        end
      end
  end
  
  def checkPutownpieceTest(array, before_pos, piece, turn, board, turn_board, own_piece=@game.own_piece, num=1)
    
      for i in array do
        
        #ゲーム画面を更新
        @game = Game.find(@game.id)
        @game.board = board
        @game.turn_board = turn_board
        @game.own_piece = own_piece
        
        setOwnPieceCount(piece, turn, num)
        
         #手番を強引に変更する
        set_turn(turn)
        @game.save
      
        #前回までのフラッシュを削除
        flash[:danger] = nil
        
        # 着手
        patch game_path(@game, game: {before: before_pos, after: i, promote: false}), xhr: true
        if(nil != flash[:danger])
          debugger
        end
        
        # 正しく着手されているか
        assert nil == flash[:danger]
        assert @game.reload.board[i] == piece.to_s
        assert @game.reload.turn_board[i] == turn.to_s
        
        ##########################################
        if ownPieceCount(piece, turn) != num-1
          debugger
        end
        ########################################
        
        #持ち駒の数が減っているか
        assert num-1 == ownPieceCount(piece, turn)
      end
  end
  
  def checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece, num=1)
    
    array = []
    piece_i = getOrgPiece(piece)
    
    ##先手　
    turn = 1
    
    #相手の持ち駒(歩)を着手する
    before_pos = (turn^3)*100 + piece_i
    checkPutpieceTest_abnormal(array, before_pos, piece, turn, board, turn_board, own_piece)
    
    #自分の持ち駒(歩)を着手する
    before_pos = turn*100 + piece_i
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board, turn_board, own_piece)
    checkPutownpieceTest(array1, before_pos, piece, turn, board, turn_board, own_piece, num)
    
    ##後手
    turn = 2
    
    #相手の持ち駒を着手する
    before_pos = (turn^3)*100 + piece_i
    checkPutpieceTest_abnormal(array, before_pos, piece, turn, board, turn_board, own_piece)
    
    #自分の持ち駒(歩)を着手する
    before_pos = turn*100 + piece_i
    checkPutpieceTest_abnormal(array2, before_pos, piece, turn, board, turn_board, own_piece)
    checkPutownpieceTest(array2, before_pos, piece, turn, board, turn_board, own_piece, num)
    
  end
  
  def check_promote(before_pos, after_pos, promote, piece, turn)
    
    initial = "000000000" + 
              "000000000" + 
              "000000000" + 
              "000000000" + 
              "000000000" +
              "000000000" +
              "000000000" +
              "000000000" +
              "000000000"
    
    #手番を強引に変更する
    set_turn(turn)
      
    #ゲーム画面を更新
    @game.board = initial
    @game.board[before_pos] = piece
    @game.turn_board = initial
    @game.turn_board[before_pos] = turn.to_s
    @game.save
    
    # 着手
    patch game_path(@game, game: {before: before_pos, after: after_pos, promote: promote}), xhr: true
    
    after_piece = @game.get_promote_piece(piece)
    
    if promote
      assert @game.reload.board[after_pos] == after_piece
    else
      assert @game.reload.board[after_pos] == piece
    end
  end
  
  test "make game model process" do
    assert @game.first_user_name == users(:test1).name
    assert @game.second_user_name == users(:test2).name
    assert @game.turn == 1
    assert @game.board== "234565432" + 
                         "080000070" + 
                         "111111111" + 
                         "000000000" + 
                         "000000000" +
                         "000000000" +
                         "111111111" +
                         "070000080" +
                         "234565432"
    assert @game.turn_board == "222222222" +
                               "020000020" +
                               "222222222" +
                               "000000000" +
                               "000000000" +
                               "000000000" +
                               "111111111" +
                               "010000010" +
                               "111111111"
    assert @game.own_piece == "000" +
                              "100" +
                              "200" +
                              "300" +
                              "400" +
                              "500" +
                              "600" +
                              "700" +
                              "800"
    assert @game.first_user_board == 0
    assert @game.second_user_board == 0
  end
  
  test "reverse" do
    
    #反転要求が先手のみ表示されていること
    assert @game.reload.first_user_board == 0
    assert @game.reload.second_user_board == 0
    assert_select "input[name=?]", "game[first_board]", count: 2
    assert_select "input[name=?]", "game[second_board]", count: 0
    assert_select "input[type=?]", "checkbox", count: 1
    assert_select "input[checked=?]", "checked", count: 0
    
    #反転要求実施時、反転要求が先手のみ変更されていること
    patch "/games/#{@game.id}/editBoard", params:{ game: {first_board: 1} }
    assert @game.reload.first_user_board == 1
    assert @game.reload.second_user_board == 0
    follow_redirect!
    assert_select "input[name=?]", "game[first_board]", count: 2
    assert_select "input[name=?]", "game[second_board]", count: 0
    assert_select "input[type=?]", "checkbox", count: 1
    assert_select "input[checked=?]", "checked", count: 1
    
    #テスト2としてログイン
    get login_path
    login_as(@test2)
    
    #ゲーム画面へ移動
    get game_path(@game)
    
    #反転要求が後手のみ表示されていること
    assert @game.reload.first_user_board == 1
    assert @game.reload.second_user_board == 0
    assert_select "input[name=?]", "game[first_board]", count: 0
    assert_select "input[name=?]", "game[second_board]", count: 2
    assert_select "input[type=?]", "checkbox", count: 1
    assert_select "input[checked=?]", "checked", count: 0
    
    #未実装　先手の判定要求が実施できないこと
    ##############################
    #############################
    ############################
    
    #反転要求実施時、反転要求が後手のみ変更されていること
    patch "/games/#{@game.id}/editBoard", params:{ game: {second_board: 1} }
    assert @game.reload.first_user_board == 1
    assert @game.reload.second_user_board == 1
    follow_redirect!
    assert_select "input[name=?]", "game[first_board]", count: 0
    assert_select "input[name=?]", "game[second_board]", count: 2
    assert_select "input[type=?]", "checkbox", count: 1
    assert_select "input[checked=?]", "checked", count: 1
    
    #再度反転要求を実施し、反転が解除されることを確認する
    patch "/games/#{@game.id}/editBoard", params:{ game: {second_board: 0} }
    assert @game.reload.first_user_board == 1
    assert @game.reload.second_user_board == 0
    follow_redirect!
    assert_select "input[name=?]", "game[first_board]", count: 0
    assert_select "input[name=?]", "game[second_board]", count: 2
    assert_select "input[type=?]", "checkbox", count: 1
    assert_select "input[checked=?]", "checked", count: 0
  end
  
  #相手の駒を着手できないこと
  #2手連続で指せないこと
  
  
  #歩
  test "fu" do
    
    #先手番
    before_pos1 = 58
    before_pos2 = 57
    piece = "1"
    turn = 1
    array1 = [49]
    array2 = [48]
    board      = "234565432" + 
                 "080000070" + 
                 "000000000" + 
                 "000000000" + 
                 "000010000" +
                 "111101111" +
                 "111111111" +
                 "070000080" +
                 "234565432"
                 
    turn_board = "222222222" +
                 "020000020" +
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "222202222" +
                 "111111111" +
                 "010000010" +
                 "111111111"
    #5七の歩を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #5七の歩を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #5七の歩を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番でも同様に操作できることを確認する
    before_pos1 = 40
    before_pos2 = 45
    piece = "1"
    turn = 2
    array1 = [49]
    array2 = [54]
    
    #歩を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #歩を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #歩を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #最後に反転要求を出すことで、表示が反転していることを確認する
    ########################################
    ####################################
  end
  
  #香車
  test "kyosya" do
    #先手番
    before_pos = 72
    piece = "2"
    turn = 1
    array1 = [27, 36, 45, 54, 63]
    array2 = [18]
    board =      "234565432" + 
                 "080000070" + 
                 "111111110" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "011111111" +
                 "070000080" +
                 "234565432"
                 
    turn_board = "222222222" +
                 "020000020" +
                 "222222220" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "011111111" +
                 "010000010" +
                 "111111111"
                        
    #9九の香車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1|array2, before_pos, piece, turn, board, turn_board)
    
    #9九の香車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board, turn_board)
    
    #9九の香車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board, turn_board)
    
    #後手番
    before_pos = 8
    piece = "2"
    turn = 2
    array1 = [17, 26, 35, 44, 53]
    array2 = [62]
    
    #9九の香車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1|array2, before_pos, piece, turn, board, turn_board)
    
    #9九の香車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board, turn_board)
    
    #9九の香車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board, turn_board)
    
  end
  
  #桂馬
  test "keima" do
    #先手番
    before_pos1 = 79
    before_pos2 = 73
    before_pos3 = 37
    piece = "3"
    turn = 1
    array1 = []
    array2 = [54, 56]
    array3 = [18, 20]
    board =      "000565432" + 
                 "000000070" + 
                 "234111111" + 
                 "000000000" + 
                 "030000030" +
                 "000000000" +
                 "030111111" +
                 "070000080" +
                 "234565432"
                 
    turn_board = "000222222" +
                 "000000020" +
                 "222222222" +
                 "000000000" +
                 "010000020" +
                 "000000000" +
                 "020111111" +
                 "010000010" +
                 "111111111"
                        
    #桂馬を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #桂馬を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #桂馬を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array3, before_pos3, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 7
    before_pos2 = 19
    before_pos3 = 43
    piece = "3"
    turn = 2
    array1 = []
    array2 = [36, 38]
    array3 = [60, 62]
    
    #桂馬を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #桂馬を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #桂馬を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array3, before_pos3, piece, turn, board, turn_board)
  end
  
  #銀
  test "gin" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "4"
    turn = 1
    array1 = [54, 55, 56, 72, 74]
    array2 = [0, 1, 2, 18, 20]
    board =      "234565000" + 
                 "040000040" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "040000040" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #銀を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #銀を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #銀を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [6, 8, 24, 25, 26]
    array2 = [78, 79, 80, 60, 62]
    
    #銀を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #銀を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #銀を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #金
  test "kin" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "5"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 73]
    array2 = [0, 1, 2, 9, 11, 19]
    board =      "234565000" + 
                 "050000050" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "050000050" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [7, 15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 61]
    
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #玉
  test "gyoku" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "6"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 72, 73, 74]
    array2 = [0, 1, 2, 18, 19, 20]
    board =      "222222000" + 
                 "000000000" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "060000000" +
                 "000222222"
                 
    turn_board = "222222000" +
                 "000000000" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000000" +
                 "000111111"
                        
    #玉を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    board =      "111111000" + 
                 "060000000" + 
                 "333333000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "000000000" +
                 "000222222"
                 
    turn_board = "222222000" +
                 "010000000" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "000000000" +
                 "000111111"
    
    #玉を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [6, 7, 8,  15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 60, 61, 62]
    board =      "222222000" + 
                 "000000060" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "000000000" +
                 "000222222"
                 
    turn_board = "222222000" +
                 "000000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "000000000" +
                 "000111111"
    
    #玉を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    board =      "222222000" + 
                 "000000000" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000333333" +
                 "000000060" +
                 "000111111"
                 
    turn_board = "222222000" +
                 "000000000" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "000000020" +
                 "000111111"
    
    #玉を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #角
  test "kaku" do
    #先手番
    before_pos = 40
    piece = "7"
    turn = 1
    
    array1 = [0, 10, 20, 30, 50, 60, 70, 80, 8, 16, 24, 32, 48, 56, 64, 72]
    board1 =      "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000070000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
                 
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000010000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [20, 30, 50, 60, 24, 32]
    board2 =      "000000000" + 
                  "010000000" + 
                  "000000100" + 
                  "000000000" + 
                  "000070000" +
                  "000100000" +
                  "000000100" +
                  "000000000" +
                  "000000000"
                 
    turn_board2 = "000000000" + 
                  "010000000" + 
                  "000000200" + 
                  "000000000" + 
                  "000010000" +
                  "000100000" +
                  "000000200" +
                  "000000000" +
                  "000000000"
                        
    #角を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #角を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #角を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
    
    #後手番
    turn = 2
    array1 = [0, 10, 20, 30, 50, 60, 70, 80, 8, 16, 24, 32, 48, 56, 64, 72]
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000020000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [10, 20, 30, 50, 32, 48]
    turn_board2 = "000000000" + 
                  "010000000" + 
                  "000000200" + 
                  "000000000" + 
                  "000020000" +
                  "000100000" +
                  "000000200" +
                  "000000000" +
                  "000000000"
    
    #角を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    # #角を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    # #角を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
  end
  
  #飛車
  test "hisya" do
    #先手番
    before_pos = 40
    piece = "8"
    turn = 1
    
    array1 = [4, 13, 22, 31, 49, 58, 67, 76, 36, 37, 38, 39, 41, 42, 43, 44]
    board1 =      "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000080000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
                 
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000010000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [13, 22, 31, 49, 38, 39, 41, 42]
    board2 =      "000000000" + 
                  "000010000" + 
                  "000000000" + 
                  "000000000" + 
                  "010080100" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
                 
    turn_board2 = "000000000" + 
                  "000020000" + 
                  "000000000" + 
                  "000000000" + 
                  "010010200" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
                        
    #飛車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
    
    #後手番
    turn = 2
    array1 = [4, 13, 22, 31, 49, 58, 67, 76, 36, 37, 38, 39, 41, 42, 43, 44]
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000020000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [22, 31, 49, 58, 37, 38, 39, 41]
    turn_board2 = "000000000" + 
                  "000020000" + 
                  "000000000" + 
                  "000000000" + 
                  "010020200" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
    #飛車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
  end
  
  #と金
  test "tokin" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "9"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 73]
    array2 = [0, 1, 2, 9, 11, 19]
    board =      "234565000" + 
                 "090000090" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "090000090" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [7, 15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 61]
    
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #成香
  test "narikyou" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "a"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 73]
    array2 = [0, 1, 2, 9, 11, 19]
    board =      "234565000" + 
                 "0a00000a0" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "0a00000a0" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [7, 15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 61]
    
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #成桂
  test "narikei" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "b"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 73]
    array2 = [0, 1, 2, 9, 11, 19]
    board =      "234565000" + 
                 "0b00000b0" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "0b00000b0" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [7, 15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 61]
    
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #成銀
  test "narigin" do
    #先手番
    before_pos1 = 64
    before_pos2 = 10
    piece = "c"
    turn = 1
    array1 = [54, 55, 56, 63, 65, 73]
    array2 = [0, 1, 2, 9, 11, 19]
    board =      "234565000" + 
                 "0c00000c0" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "0c00000c0" +
                 "000565432"
                 
    turn_board = "222222000" +
                 "010000020" +
                 "222222000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "010000020" +
                 "000111111"
                        
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [7, 15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 61]
    
    #金を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #金を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #馬
  test "uma" do
    #先手番
    before_pos = 40
    piece = "e"
    turn = 1
    
    array1 = [0, 10, 20, 30, 50, 60, 70, 80, 8, 16, 24, 32, 48, 56, 64, 72, 39, 41, 31, 49]
    board1 =      "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "0000e0000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
                 
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000010000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [20, 30, 50, 60, 24, 32, 39, 41, 31, 49]
    board2 =      "000000000" + 
                  "010000000" + 
                  "000000100" + 
                  "000000000" + 
                  "0000e0000" +
                  "000100000" +
                  "000000100" +
                  "000000000" +
                  "000000000"
                 
    turn_board2 = "000000000" + 
                  "010000000" + 
                  "000000200" + 
                  "000000000" + 
                  "000010000" +
                  "000100000" +
                  "000000200" +
                  "000000000" +
                  "000000000"
                        
    #角を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #角を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #角を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
    
    #後手番
    turn = 2
    #array1 = [0, 10, 20, 30, 50, 60, 70, 80, 8, 16, 24, 32, 48, 56, 64, 72]
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000020000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [10, 20, 30, 50, 32, 48, 39, 41, 31, 49]
    turn_board2 = "000000000" + 
                  "010000000" + 
                  "000000200" + 
                  "000000000" + 
                  "000020000" +
                  "000100000" +
                  "000000200" +
                  "000000000" +
                  "000000000"
    
    #角を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    # #角を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    # #角を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
  end
  
  #龍
  test "ryuu" do
    #先手番
    before_pos = 40
    piece = "f"
    turn = 1
    
    array1 = [4, 13, 22, 31, 49, 58, 67, 76, 36, 37, 38, 39, 41, 42, 43, 44, 30, 32, 48, 50]
    board1 =      "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "0000f0000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
                 
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000010000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [13, 22, 31, 49, 38, 39, 41, 42, 30, 32, 48, 50]
    board2 =      "000000000" + 
                  "000010000" + 
                  "000000000" + 
                  "000000000" + 
                  "0100f0100" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
                 
    turn_board2 = "000000000" + 
                  "000020000" + 
                  "000000000" + 
                  "000000000" + 
                  "010010200" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
                        
    #飛車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
    
    #後手番
    turn = 2
    #array1 = [4, 13, 22, 31, 49, 58, 67, 76, 36, 37, 38, 39, 41, 42, 43, 44]
    turn_board1 = "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000000000" + 
                  "000020000" +
                  "000000000" +
                  "000000000" +
                  "000000000" +
                  "000000000"
    
    array2 = [22, 31, 49, 58, 37, 38, 39, 41, 30, 32, 48, 50]
    turn_board2 = "000000000" + 
                  "000020000" + 
                  "000000000" + 
                  "000000000" + 
                  "010020200" +
                  "000000000" +
                  "000010000" +
                  "000000000" +
                  "000000000"
    #飛車を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos, piece, turn, board1, turn_board1)
    
    #飛車を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos, piece, turn, board2, turn_board2)
  end
  
  #持ち駒
  test "own_piece" do
    
    board =     "000000000" + 
                "000000000" + 
                "222222222" + 
                "000000000" + 
                "000000000" +
                "000000000" +
                "222222222" +
                "070000080" +
                "000000000"
    turn_board ="000000000" +
                "000000000" +
                "222222222" +
                "000000000" +
                "000000000" +
                "000000000" +
                "111111111" +
                "010000010" +
                "000000000"
    own_piece = "000" +
                "111" +
                "211" +
                "311" +
                "411" +
                "511" +
                "611" +
                "711" +
                "811"
    
    #歩
    piece = "1"
    array1 = [ 9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71,
              72, 73, 74, 75, 76, 77, 78, 79, 80]
    array2 = [ 0,  1,  2,  3,  4,  5,  6,  7,  8,
               9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71]
    checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece)
    
    #香車
    piece = "2"
    checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece)
    
    #桂馬
    piece = "3"
    array1 = [27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71,
              72, 73, 74, 75, 76, 77, 78, 79, 80]
    array2 = [ 0,  1,  2,  3,  4,  5,  6,  7,  8,
              9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53]
    checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece)
    
    #銀
    piece = "4"
    array1 = [ 0,  1,  2,  3,  4,  5,  6,  7,  8,
               9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71,
              72, 73, 74, 75, 76, 77, 78, 79, 80]
    checkPutOwnpieceAll(array1, array1, piece, board, turn_board, own_piece)
    
    #金
    piece = "5"
    checkPutOwnpieceAll(array1, array1, piece, board, turn_board, own_piece)
    
    # #玉
    # piece = "6"
    # checkPutOwnpieceAll(array1, array1, piece, board, turn_board, own_piece)
    
    #角
    piece = "7"
    checkPutOwnpieceAll(array1, array1, piece, board, turn_board, own_piece)
    
    #飛車
    piece = "8"
    checkPutOwnpieceAll(array1, array1, piece, board, turn_board, own_piece)
  end
  
  #持ち駒をたくさん持っている場合
  test "many_own_piece" do
    
    board =     "000000000" + 
                "000000000" + 
                "222222222" + 
                "000000000" + 
                "000000000" +
                "000000000" +
                "222222222" +
                "070000080" +
                "000000000"
    turn_board ="000000000" +
                "000000000" +
                "222222222" +
                "000000000" +
                "000000000" +
                "000000000" +
                "111111111" +
                "010000010" +
                "000000000"
    own_piece = "000" +
                "1aa" +
                "211" +
                "311" +
                "411" +
                "511" +
                "611" +
                "711" +
                "811"
    
    #歩
    piece = "1"
    array1 = [ 9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71,
              72, 73, 74, 75, 76, 77, 78, 79, 80]
    array2 = [ 0,  1,  2,  3,  4,  5,  6,  7,  8,
               9, 10, 11, 12, 13, 14, 15, 16, 17,
              27, 28, 29, 30, 31, 32, 33, 34, 35,
              36, 37, 38, 39, 40, 41, 42, 43, 44,
              45, 46, 47, 48, 49, 50, 51, 52, 53,
              63,     65, 66, 67, 68, 69,     71]
    checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece, 10)
    for i in 1..18 do
      checkPutOwnpieceAll(array1, array2, piece, board, turn_board, own_piece, i)
    end
    
  end
  
  ###成判定
  def checkDisplaySelect(array1, array2, array3, piece, array4, turn)
    
    initial = "000000000" + 
              "000000000" + 
              "000000000" + 
              "000000000" + 
              "000000000" +
              "000000000" +
              "000000000" +
              "000000000" +
              "000000000"
    
    array1.length.times do |i|
      
      #手番を強引に変更する
      set_turn(turn)
      
      #ゲーム画面を更新
      @game.board = initial
      @game.board[array1[i].to_i] = piece
      @game.turn_board = initial
      @game.turn_board[array1[i].to_i] = turn.to_s
      @game.save
      
      before = array1[i]
      after = array2[i]
      judge = array3[i]
      after_piece = array4[i]
      
      # 着手
      patch game_path(@game, game: {before: before, after: after}), xhr: true
      
      # follow_redirect!
      
      if judge
        # assert_template "games/confirm"
        # assert_select "div#backRegion", count: 1
        assert @game.reload.board[after] != after_piece
      else
        if @game.reload.board[after] != after_piece
          debugger
        end
        # assert_template "games/show"
        # assert_select "div#backRegion", count: 0
        assert @game.reload.board[after] == after_piece
      end
    end
  end
  
  test "display_promote" do
    #歩
    checkDisplaySelect([36, 27, 18, 9],  [27, 18, 9, 0],   [false, true, true, false], "1", ["1", "9", "9", "9"], 1)
    checkDisplaySelect([36, 45, 54, 63], [45, 54, 63, 72], [false, true, true, false], "1", ["1", "9", "9", "9"], 2)
    
    #香車
    checkDisplaySelect([36, 27, 18, 9],  [27, 18, 9, 0],   [false, true, true, false], "2", ["2", "a", "a", "a"], 1)
    checkDisplaySelect([36, 45, 54, 63], [45, 54, 63, 72], [false, true, true, false], "2", ["2", "a", "a", "a"], 2)
    
    #桂馬
    checkDisplaySelect([49, 40, 31, 22], [30, 21, 12, 3],  [false, true, false, false], "3", ["3", "b", "b", "b"], 1)
    checkDisplaySelect([31, 40, 49, 58], [48, 57, 66, 75], [false, true, false, false], "3", ["3", "b", "b", "b"], 2)
    
    #銀
    checkDisplaySelect([36, 27, 18, 9, 18],  [27, 18, 9, 0, 28],   [false, true, true, true, true], "4", ["4", "c", "c", "c", "c"], 1)
    checkDisplaySelect([36, 45, 54, 63, 54], [45, 54, 63, 72, 46], [false, true, true, true, true], "4", ["4", "c", "c", "c", "c"], 2)
    
    #金
    checkDisplaySelect([36, 27, 18, 9, 18],  [27, 18, 9, 0, 27],   [false, false, false, false, false], "5", ["5", "5", "5", "5", "5"], 1)
    checkDisplaySelect([36, 45, 54, 63, 54], [45, 54, 63, 72, 45], [false, false, false, false, false], "5", ["5", "5", "5", "5", "5"], 2)
    
    #玉
    checkDisplaySelect([36, 27, 18, 9, 18],  [27, 18, 9, 0, 27],   [false, false, false, false, false], "6", ["6", "6", "6", "6", "6"], 1)
    checkDisplaySelect([36, 45, 54, 63, 54], [45, 54, 63, 72, 45], [false, false, false, false, false], "6", ["6", "6", "6", "6", "6"], 2)
    
    #角
    checkDisplaySelect([40, 40, 40, 40, 10], [70, 20, 10, 0, 40],  [false, true, true, true, true], "7", ["7", "e", "e", "e", "e"], 1)
    checkDisplaySelect([40, 40, 40, 40, 70], [10, 60, 70, 80, 40],  [false, true, true, true, true], "7", ["7", "e", "e", "e", "e"], 2)
    
    #飛車
    checkDisplaySelect([36, 36, 36, 36, 18], [27, 18,  9, 0, 36],  [false, true, true, true, true], "8", ["8", "f", "f", "f", "f"], 1)
    checkDisplaySelect([36, 36, 36, 36, 63], [45, 54, 63, 72, 0],  [false, true, true, true, true], "8", ["8", "f", "f", "f", "f"], 2)
  end
  
  ### 成
  test "promote_process" do
    #歩
    check_promote(31, 22, true, "1", 1)
    check_promote(31, 22, false, "1", 1)
    check_promote(49, 58, true, "1", 2)
    check_promote(49, 58, false, "1", 2)
    
    #香車
    check_promote(31, 22, true, "2", 1)
    check_promote(31, 22, false, "2", 1)
    check_promote(49, 58, true, "2", 2)
    check_promote(49, 58, false, "2", 2)
    
    #桂馬
    check_promote(41, 22, true, "3", 1)
    check_promote(41, 22, false, "3", 1)
    check_promote(39, 58, true, "3", 2)
    check_promote(39, 58, false, "3", 2)
    
    #銀
    check_promote(31, 22, true, "4", 1)
    check_promote(31, 22, false, "4", 1)
    check_promote(49, 58, true, "4", 2)
    check_promote(49, 58, false, "4", 2)
    
    #金
    check_promote(31, 22, true, "5", 1)
    check_promote(31, 22, false, "5", 1)
    check_promote(49, 58, true, "5", 2)
    check_promote(49, 58, false, "5", 2)
    
    #玉
    check_promote(31, 22, true, "6", 1)
    check_promote(31, 22, false, "6", 1)
    check_promote(49, 58, true, "6", 2)
    check_promote(49, 58, false, "6", 2)
    
    #角
    check_promote(32, 22, true, "7", 1)
    check_promote(32, 22, false, "7", 1)
    check_promote(48, 58, true, "7", 2)
    check_promote(48, 58, false, "7", 2)
    
    #飛車
    check_promote(31, 22, true, "8", 1)
    check_promote(31, 22, false, "8", 1)
    check_promote(49, 58, true, "8", 2)
    check_promote(49, 58, false, "8", 2)
  end
  
  def finish(judge)
    @game.board =     "000060000" + 
                      "000000000" + 
                      "100510000" + 
                      "000000000" + 
                      "000000000" +
                      "000000000" +
                      "000015000" +
                      "000000000" +
                      "000060000"
                       
   @game.turn_board = "000020000" +
                      "000000000" +
                      "100110000" +
                      "000000000" +
                      "000000000" +
                      "000000000" +
                      "000022000" +
                      "000000000" +
                      "000010000"
    @game.save
    set_turn(@FIRST)
    
    if judge
      before_pos = 21
      after_pos = 13
      patch game_path(@game, game: {before: before_pos, after: after_pos, promote: false}), xhr: true
      
      assert @game.reload.winner == @FIRST
      # assert_select "div#finish", count: 1
      # assert_select "img[src=?]", "/shogi/pose_win.png", count: 1
    else
      before_pos = 18
      after_pos = 9
      patch game_path(@game, game: {before: before_pos, after: after_pos, promote: false} ), xhr: true
      
      set_turn(@SECOND)
      before_pos = 59
      after_pos = 67
      patch game_path(@game, game: {before: before_pos, after: after_pos, promote: false} ), xhr: true
      
      assert @game.reload.winner == @SECOND
      # assert_select "div#finish", count: 1
      # assert_select "img[src=?]", "/shogi/pose_lose.png", count: 1
    end
  end
  
  ###勝敗
  test "finish" do
    
    finish(true)
    finish(false)
  end
  
  def check_two_fu(turn, board, turn_board, own_piece, is_judge)
    
    before_pos = 100*turn + 1
    
    for after_pos in 36..44 do
      @game.board = board
      @game.turn_board = turn_board
      @game.own_piece = own_piece
      set_turn(turn)
      @game.save
      
      #移動先の盤面情報を取得
      opp_piece = @game.board[after_pos]
      piece = "1"
      num = ownPieceCount(piece, turn)
      # before_piece = @game.board[before_pos]
    
      #着手する
      patch game_path(@game, game: {before: before_pos, after: after_pos, promote: false}), xhr: true
      
      if is_judge
        # 正しく着手されているか
        assert @game.reload.board[after_pos] == piece
        assert @game.reload.turn_board[after_pos] == turn.to_s
        
        #持ち駒の数が減っているか
        assert num-1 == ownPieceCount(piece, turn)
        
      else
        assert @game.reload.board[after_pos] == opp_piece
        assert num == ownPieceCount(piece, turn)
      end
    end
  end
  
  ###2歩
  test "two_fu_integration" do
    board =      "000000000"+ 
                 "000000000" + 
                 "000000000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "111111111" +
                 "000000000" +
                 "000000000"
                 
    turn_board = "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "111111111" +
                 "000000000" +
                 "000000000"
                 
    own_piece  = "000" +
                 "111" +
                 "200" +
                 "300" +
                 "400" +
                 "500" +
                 "600" +
                 "700" +
                 "800"
    
    check_two_fu(@FIRST, board, turn_board, own_piece, false)
    check_two_fu(@SECOND, board, turn_board, own_piece, true)
    
    board =      "000000000"+ 
                 "000000000" + 
                 "111111111" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000"
                 
    turn_board = "000000000" + 
                 "000000000" +
                 "222222222" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000000000"
    
    check_two_fu(@FIRST, board, turn_board, own_piece, true)
    check_two_fu(@SECOND, board, turn_board, own_piece, false)
  end
  
  ###王手放置テスト
  def oute_leave(before_pos, after_pos, turn, board, turn_board, is_judge)
    @game.board = board
    @game.turn_board = turn_board
    set_turn(turn)
    @game.save
      
    #移動先の盤面情報を取得
    opp_piece = @game.board[after_pos]
    piece = @game.board[before_pos]
    num = ownPieceCount(piece, turn)
    
    #着手する
    patch game_path(@game, game: {before: before_pos, after: after_pos, promote: false}), xhr: true
    
    if is_judge
      #着手成功
      assert @game.reload.board[after_pos] == piece
      assert @game.reload.turn_board[after_pos] == turn.to_s
    else
      #王手放置のため着手失敗
      assert @game.reload.board[after_pos] == opp_piece
      assert num == ownPieceCount(piece, turn)
    end
  end
  
  test "oute_leave" do
    
    board =      "000060000" + 
                 "000000000" + 
                 "100050000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "100050000" +
                 "000010000" +
                 "000060000"
                 
    turn_board = "000020000" + 
                 "000000000" +
                 "100010000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "200020000" +
                 "000020000" +
                 "000010000"
    oute_leave(18, 9, @FIRST, board, turn_board, false)
    oute_leave(54, 63, @SECOND, board, turn_board, true)
    
    board =      "000060000" + 
                 "000010000" + 
                 "100050000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000050000" +
                 "100000000" +
                 "000060000"
                 
    turn_board = "000020000" + 
                 "000010000" +
                 "100010000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "200000000" +
                 "000010000"
    oute_leave(18, 9, @FIRST, board, turn_board, true)
    oute_leave(63, 72, @SECOND, board, turn_board, false)
    
    board =      "230500000" + 
                 "040006e0f" + 
                 "101111301" + 
                 "000000010" + 
                 "000000020" +
                 "001000000" +
                 "150011101" +
                 "000056040" +
                 "2000005f2"
                 
    turn_board = "220200000" + 
                 "020002101" +
                 "202222202" +
                 "000000020" +
                 "000000020" +
                 "001000000" +
                 "110011101" +
                 "000011010" +
                 "100000121"
    oute_leave(14, 13, @SECOND, board, turn_board, true)
    
  end
  
end
