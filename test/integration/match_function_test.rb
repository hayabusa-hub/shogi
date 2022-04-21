require 'test_helper'

class MatchFunctionTest < ActionDispatch::IntegrationTest
  include GamesHelper
  def setup
    @michael = users(:michael)
    @alice = users(:alice)
    @test1 = users(:test1)
    @test2 = users(:test2)
    @test3 = users(:test3)
  end
  
  #指定したユーザーが対局室へ入場する
  def enter_room(user)
    #ログイン
    login_as(user)
    
    #対局室へ移動
    post matchs_path, params: {user_id: user.id}
  end
  
  #user1がuser2へ対戦要求を出す
  def request_match(user1, user2, status)
    #user2としてログインし、対局室へ入場
    enter_room(user2)
    
    #ログアウト
    delete logout_path
    
    #user1としてログインし、対局室へ入場
    enter_room(user1)
    
    #user1からuser2へ対戦要求を行う
    patch match_path(user1.match), params: { opponent_id: user2.id, status: status }
  end
  
  #正常系 ホームの「対局室へ移動」をクリックしたときに対局室へ移動するか　そのときにMatchモデルが生成されるか
  test "move to battle room" do
    login_as(@michael)
    get root_path
    assert_difference "Match.count", 1 do
      post matchs_path, params: {user_id: @michael.id}
    end
    assert_redirected_to matchs_path
    
    assert_no_difference "Match.count" do
      get root_path
      post matchs_path, params: {user_id: @michael.id}
    end
    assert_redirected_to matchs_path
    
    matchs = assigns(:match)
    assert matchs.user_id == @michael.id
  end
  
  #対戦要求を承諾したときの挙動
  test "behavior accept match" do
    
    #test1からtest2へ対戦要求を行う
    request_match(@test1, @test2, WAITING)
    
    #test1の確認
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs.user_id == @test1.id
    assert matchs.opponent_id == @test2.id
    assert matchs.status == 1
    
    #test2の確認
    matchs = Match.find_by(user_id: @test2.id)
    assert matchs.user_id == @test2.id
    assert matchs.opponent_id == @test1.id
    assert matchs.status == 1
    
    #test2の画面の確認
    enter_room(@test2)
    follow_redirect!
    assert_select "input[value=?]", "承諾"
    assert_select "input[value=?]", "拒否"
    
    #test2が対戦要求を承諾する
    patch match_path(@test2.match, opponent_id: @test1.id, status: PLAYING)
    
    #test1の確認
    login_as(@test1)
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs.user_id == @test1.id
    assert matchs.opponent_id == @test2.id
    assert matchs.status == PLAYING
    
    #test2の確認
    login_as(@test2)
    matchs = Match.find_by(user_id: @test2.id)
    assert matchs.user_id == @test2.id
    assert matchs.opponent_id == @test1.id
    assert matchs.status == PLAYING
    
    #ゲーム画面へ移動し、ゲームモデルが作成されることを確認する
    # assert_redirected_to
  end
  
  #対戦要求を拒否したときの挙動
  test "behavior match decline" do
    
    #test1からtest2へ対戦要求を行う
    request_match(@test1, @test2, WAITING)
    
    #test1の確認
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs.user_id == @test1.id
    assert matchs.opponent_id == @test2.id
    assert matchs.status == WAITING
    
    #test2の画面の確認
    enter_room(@test2)
    follow_redirect!
    assert_select "input[value=?]", "承諾"
    assert_select "input[value=?]", "拒否"
    
    #test2が対戦要求を拒否する
    patch match_path(@test2.match, opponent_id: @test1.id, status: DECLINE)
    
    #test1の確認
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs.user_id == @test1.id
    assert matchs.opponent_id == 0
    assert matchs.status == STANDBY
    
    #test2の確認
    matchs = Match.find_by(user_id: @test2.id)
    assert matchs.user_id == @test2.id
    assert matchs.opponent_id == 0
    assert matchs.status == STANDBY
    
    #対戦要求が拒否された旨を表示する
    delete logout_path
    get root_path
    login_as(@test1)
    post matchs_path, params: {user_id: @test1.id}
    follow_redirect!
    assert_not flash[:info].empty?
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs.user_id == @test1.id
    assert matchs.opponent_id == 0
    assert matchs.status == 0
    get root_path
    get matchs_path
    assert flash.empty?
    
    #対局室から移動する
    delete match_path(@test1)
    assert_redirected_to root_path
    matchs = Match.find_by(user_id: @test1.id)
    assert matchs == nil
  end
  
  #対戦要求がすでに別のユーザーから出されている場合は、対戦要求できない
  test "duplicate match request" do
    
    #test1がマイケルへ対戦要求を行う
    request_match(@test1, @michael, WAITING)
    
    #マイケルがアリスへ対戦要求を行う
    request_match(@test2, @michael, WAITING)
    
    #マイケルの状態
    match_ = Match.find_by(user_id: @michael.id)
    assert match_.user_id == @michael.id
    assert match_.opponent_id == @test1.id
    assert match_.status == WAITING
    
    #test1の状態
    match_ = Match.find_by(user_id: @test1.id)
    assert match_.user_id == @test1.id
    assert match_.opponent_id == @michael.id
    assert match_.status == WAITING
    
    #test2の状態
    match_ = Match.find_by(user_id: @test2.id)
    assert match_.user_id == @test2.id
    assert match_.opponent_id == 0
    assert match_.status == STANDBY
  end
  
  #対戦要求を同時に2つ以上出せない
  test "cannot request match to multiple users at the same time" do
    
    #test1がtest2へ対戦要求を行う
    request_match(@test1, @test2, WAITING)
    
    #test1がtest3へ対戦要求を行う
    request_match(@test1, @test3, WAITING)
    
    #test1の状態
    match_ = Match.find_by(user_id: @test1.id)
    assert match_.user_id == @test1.id
    assert match_.opponent_id == @test2.id
    assert match_.status == WAITING
    
    #test2の状態
    match_ = Match.find_by(user_id: @test2.id)
    assert match_.user_id == @test2.id
    assert match_.opponent_id == @test1.id
    assert match_.status == WAITING
    
    #test3の状態
    match_ = Match.find_by(user_id: @test3.id)
    assert match_.user_id == @test3.id
    assert match_.opponent_id == 0
    assert match_.status == STANDBY
  end
end
