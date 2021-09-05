require 'test_helper'

class GameFunctionTest < ActionDispatch::IntegrationTest
  def setup
    @test1 = users(:test1)
    @test2 = users(:test2)
    @game = Game.new()
    @game.board_init(@test1.id, @test2.id)
    @game.save
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
    #テスト1としてログイン
    get login_path
    login_as(@test1)
    
    #ゲーム画面へ移動
    get game_path(@game)
    
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
end
