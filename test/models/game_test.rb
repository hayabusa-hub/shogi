require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @test1 = users(:test1)
    @test2 = users(:test2)
    @game = Game.new()
    @game.board_init(@test1.id, @test2.id)
    @game.save
   
    
    @FIRST = 1
    @SECOND = 2
    
  end
  
  def set_turn(turn)
    if 1 == turn
      @game.first_user_id = @test1.id
      @game.second_user_id = @test2.id
    elsif 2 == turn
      @game.first_user_id = @test2.id
      @game.second_user_id = @test1.id
    end
  end
  
  def set_king_pos(board, turn_board)
    for pos in 0..board.length do
      if ("6" == board[pos])
        if (@FIRST == turn_board[pos].to_i)
          @game.first_king_pos = pos
        elsif (@SECOND == turn_board[pos].to_i)
          @game.second_king_pos = pos
        else
        end
      end
    end
  end
  
  def checkmate(turn, board, turn_board, is_judge, own_piece=@game.own_piece)
    @game.turn = turn
    set_turn(turn)
    set_king_pos(board, turn_board)
    
    @game.board = board
    @game.turn_board = turn_board
    @game.own_piece = own_piece
    @game.save
    
    if is_judge
      assert @game.is_checkmate?()
    else
      assert_not @game.is_checkmate?()
    end
  end
  
  test "checkmate" do
    
    # 1
    board =      "000060000" + 
                 "080050070" + 
                 "111111111" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "111111111" +
                 "070050080" +
                 "000060000"
    turn_board = "000020000" +
                 "010010020" +
                 "222222222" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "111111111" +
                 "010020020" +
                 "000010000"
    checkmate(@FIRST, board, turn_board, true)
    checkmate(@SECOND, board, turn_board, true)
    
    # 2
    board =      "000111000"+ 
                 "000060000" + 
                 "000050000" + 
                 "000010000" + 
                 "000000000" +
                 "000010000" +
                 "000050000" +
                 "000060000" +
                 "000111000"
                 
    turn_board = "000222000" + 
                 "000020000" +
                 "000010000" +
                 "000010000" +
                 "000000000" +
                 "000020000" +
                 "000020000" +
                 "000010000" +
                 "000111000"
    checkmate(@FIRST, board, turn_board, true)
    checkmate(@SECOND, board, turn_board, true)
    
    # 3
    board =      "000565000"+ 
                 "000111000" + 
                 "000003000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000003000" +
                 "000111000" +
                 "000565000"
                 
    turn_board = "000222000" + 
                 "000222000" +
                 "000001000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000002000" +
                 "000111000" +
                 "000111000"
    checkmate(@FIRST, board, turn_board, false)
    checkmate(@SECOND, board, turn_board, false)
    
    # 4
    board =      "000565000"+ 
                 "000101000" + 
                 "000020000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000565000"
                 
    turn_board = "000222000" + 
                 "000202000" +
                 "000010000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000111000"
    checkmate(@FIRST, board, turn_board, false)
    checkmate(@SECOND, board, turn_board, false)
    
    # 5
    board =      "000262000"+ 
                 "000101000" + 
                 "000020000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000262000"
                 
    turn_board = "000222000" + 
                 "000202000" +
                 "000010000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000111000"
    checkmate(@FIRST, board, turn_board, true)
    checkmate(@SECOND, board, turn_board, true)
    
     # 6
    board =      "000262000"+ 
                 "000101000" + 
                 "000020000" + 
                 "000000000" + 
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000262000"
                 
    turn_board = "000222000" + 
                 "000202000" +
                 "000010000" +
                 "000000000" +
                 "000000000" +
                 "000000000" +
                 "000020000" +
                 "000101000" +
                 "000111000"
                 
    own_piece  = "000" +
                 "111" +
                 "200" +
                 "300" +
                 "400" +
                 "500" +
                 "600" +
                 "700" +
                 "800"
    checkmate(@FIRST, board, turn_board, false, own_piece)
    checkmate(@SECOND, board, turn_board, false, own_piece)
  end
  
  def isOute(turn, board, turn_board, is_judge, own_piece=@game.own_piece)
    @game.turn = turn
    set_turn(turn)
    set_king_pos(board, turn_board)
    
    @game.board = board
    @game.turn_board = turn_board
    @game.own_piece = own_piece
    @game.save
    
    if is_judge
      #王手がかかっている
      assert @game.is_oute?()
    else
      #王手がかかっていない
      assert_not @game.is_oute?()
    end
  end
  
  test "oute" do
    
    # 1
    board =      "230500000" + 
                 "040060e0f" + 
                 "101111301" + 
                 "000000010" + 
                 "000000020" +
                 "001000000" +
                 "150011101" +
                 "000056040" +
                 "2000005f2"
                 
    turn_board = "220200000" + 
                 "020020101" +
                 "202222202" +
                 "000000020" +
                 "000000020" +
                 "001000000" +
                 "110011101" +
                 "000011010" +
                 "100000121"
    isOute(@SECOND, board, turn_board, false)
    
    # 2
    board =      "230500000" + 
                 "040060e08" + 
                 "101111301" + 
                 "000000010" + 
                 "000000020" +
                 "001000000" +
                 "150011101" +
                 "000056040" +
                 "2000005f2"
                 
    turn_board = "220200000" + 
                 "020020101" +
                 "202222202" +
                 "000000020" +
                 "000000020" +
                 "001000000" +
                 "110011101" +
                 "000011010" +
                 "100000121"
    isOute(@SECOND, board, turn_board, false)
    
  end
  
end
