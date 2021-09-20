require 'test_helper'

class GameFunctionTest < ActionDispatch::IntegrationTest
  def setup
    @test1 = users(:test1)
    @test2 = users(:test2)
    @game = Game.new()
    @game.board_init(@test1.id, @test2.id)
    @game.save
    
    #テスト1としてログイン
    get login_path
    login_as(@test1)
    
    #ゲーム画面へ移動
    get game_path(@game)
  end
  
  def ownPieceCount(piece, turn)
    @game.own_piece[piece*3+turn].to_i
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
  
  def checkPutpieceTest_abnormal(array, before_pos, piece, turn, board, turn_board)
    #ゲーム画面を更新
    @game.board = board
    @game.turn_board = turn_board
    #手番を強引に変更する
    @game.turn = turn
    @game.save
    for i in 0..80 do
      if(true == array.include?(i))
        next
      end
      flash[:danger] = nil
      
      #移動先の盤面情報を取得
      opp_piece = @game.board[i].to_i
      num = ownPieceCount(opp_piece, turn)
      
      get edit_game_path(@game), params: {before: before_pos}
      patch game_path(@game, before: before_pos, after: i)
      
      if(true == flash[:danger].empty?)
          debugger
      end
      assert_not flash[:danger].empty?
      assert @game.reload.board[before_pos] == piece.to_s
      assert @game.reload.turn_board[before_pos] == turn.to_s
      assert num == ownPieceCount(opp_piece, turn)
    end
  end
  
  def checkPutpieceTest(array, before_pos, piece, turn, board, turn_board)
    
      for i in array do
        
        #ゲーム画面を更新
        @game.board = board
        @game.turn_board = turn_board
         #手番を強引に変更する
        @game.turn = turn
        @game.save
      
        #前回までのフラッシュを削除
        flash[:danger] = nil
        
        #移動先の盤面情報を取得
        opp_piece = @game.board[i].to_i
        num = ownPieceCount(opp_piece, turn)
        
        # 着手
        get edit_game_path(@game), params: {before: before_pos}
        patch game_path(@game, before: before_pos, after: i)
        if(false == flash.empty?)
          debugger
        end
      
        # 着手前の場所には
        assert flash.empty?
        assert @game.reload.board[before_pos] == "0"
        assert @game.reload.turn_board[before_pos] == "0"
        assert @game.reload.board[i] == piece.to_s
        assert @game.reload.turn_board[i] == turn.to_s
        # assert ownPieceCount(piece, turn) == num_own_piece
        if(0 == opp_piece)
          assert num == ownPieceCount(opp_piece, turn)
        else
          assert num + 1 == ownPieceCount(opp_piece, turn)
        end
      end
    
  end
  
  test "make game model process" do
    assert @game.first_user_id == users(:test1).id
    assert @game.second_user_id == users(:test2).id
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
    piece = 1
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
    piece = 1
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
    piece = 2
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
    piece = 2
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
    before_pos3 = 19
    piece = 3
    turn = 1
    array1 = []
    array2 = [54, 56]
    array3 = [0, 2]
    board =      "234565432" + 
                 "080000070" + 
                 "030111111" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "030111111" +
                 "070000080" +
                 "234565432"
                 
    turn_board = "222222222" +
                 "020000020" +
                 "010222222" +
                 "000000000" +
                 "000000000" +
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
    before_pos2 = 1
    before_pos3 = 55
    piece = 3
    turn = 2
    array1 = []
    array2 = [18, 20]
    array3 = [72, 74]
    
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
    piece = 4
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
    piece = 5
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
    piece = 6
    turn = 1
    array1 = [54, 55, 56, 63, 65, 72, 73, 74]
    array2 = [0, 1, 2, 9, 11, 18, 19, 20]
    board =      "234565000" + 
                 "060000060" + 
                 "111111000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000111111" +
                 "060000060" +
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
                        
    #玉を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
    
    #後手番
    before_pos1 = 16
    before_pos2 = 70
    turn = 2
    array1 = [6, 7, 8,  15, 17, 24, 25, 26]
    array2 = [78, 79, 80, 69, 71, 60, 61, 62]
    
    #玉を移動できない場所へ着手する
    checkPutpieceTest_abnormal(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がない)へ着手する
    checkPutpieceTest(array1, before_pos1, piece, turn, board, turn_board)
    
    #玉を移動できる場所(相手の駒がある)へ着手する
    checkPutpieceTest(array2, before_pos2, piece, turn, board, turn_board)
  end
  
  #角
  test "kaku" do
    #先手番
    before_pos = 40
    piece = 7
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
    piece = 8
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
  
end
