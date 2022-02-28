require 'test_helper'

class MatchFunctionTest < ActionDispatch::IntegrationTest
  def setup
    @michael = users(:michael)
    @alice = users(:alice)
  end
  
  #正常系 ホームの「対局室へ移動」をクリックしたときに対局室へ移動するか　そのときにMatchモデルが生成されるか
  test "move to battle room" do
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
  
  #異常系
  # test do
  # end
  
  #対戦要求を承諾したときの挙動
  test "behavior accept match" do
    
    #ログイン
    get login_path
    login_as(@michael)
    
    #対局室へ移動
    get root_path
    post matchs_path, params: {user_id: @michael.id}
    
    #Aliceへ対戦要求を行う
    patch match_path(@michael.match), params: { opponent_id: @alice.id, status: 1 }
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs.user_id == @michael.id
    assert matchs.opponent_id == @alice.id
    assert matchs.status == 1
    
    #Aliceが対戦要求を承諾する
    delete logout_path
    get root_path
    login_as(@alice)
    post matchs_path, params: {user_id: @alice.id}
    follow_redirect!
    #assert_select "a[href=?]", match_path(@michael.match, opponent_id: @alice.id, status: 3) , text: "承諾"
    assert_select "input[value=?]", "承諾"
    #assert_select "a[href=?]", match_path(@michael.match, opponent_id: @alice.id, status: 2) , text: "拒否"
    assert_select "input[value=?]", "拒否"
    patch match_path(@alice.match, opponent_id: @michael.id, status: 3)
    
    #Michaelの確認
    login_as(@michael)
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs.user_id == @michael.id
    assert matchs.opponent_id == @alice.id
    assert matchs.status == 3
    
    #Aliceの確認
    login_as(@alice)
    matchs = Match.find_by(user_id: @alice.id)
    assert matchs.user_id == @alice.id
    assert matchs.opponent_id == @michael.id
    assert matchs.status == 3
    
    #ゲーム画面へ移動し、ゲームモデルが作成されることを確認する
    # assert_redirected_to
  end
  
  #対戦要求を出し承諾を得たときの挙動
  test "behavior accepted match" do
    #ログイン
    get login_path
    login_as(@michael)
    
    #対局室へ移動
    get root_path
    post matchs_path, params: {user_id: @michael.id}
    
    #Aliceへ対戦要求を行う
    #patch match_path(@michael.match), params: { opponent_id: @alice.id, status: 3 }
    matchs = Match.find_by(user_id: @michael.id)
    matchs.opponent_id = @alice.id
    matchs.status = 3
    matchs.save
    assert matchs.user_id == @michael.id
    assert matchs.opponent_id == @alice.id
    # assert matchs.status == 3
    #follow_redirect!
    
    #ゲーム画面へ移動する
    # assert_redirected_to
  end
  
  #対戦要求を拒否したときの挙動
  test "behavior match decline" do
    
    #ログイン
    get login_path
    login_as(@michael)
    
    #対局室へ移動
    get root_path
    post matchs_path, params: {user_id: @michael.id}
    
    #Aliceへ対戦要求を行う
    patch match_path(@michael.match), params: { opponent_id: @alice.id, status: 1 }
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs.user_id == @michael.id
    assert matchs.opponent_id == @alice.id
    assert matchs.status == 1
    
    #Aliceが対戦要求を拒否する
    delete logout_path
    get root_path
    login_as(@alice)
    post matchs_path, params: {user_id: @alice.id}
    follow_redirect!
    #assert_select "a[href=?]", match_path(@michael.match, opponent_id: @alice.id, status: 3) , text: "承諾"
    assert_select "input[value=?]", "承諾"
    #assert_select "a[href=?]", match_path(@michael.match, opponent_id: @alice.id, status: 2) , text: "拒否"
    assert_select "input[value=?]", "拒否"
    patch match_path(@michael.match, opponent_id: @alice.id, status: 2)
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs.user_id == @michael.id
    assert matchs.opponent_id == @alice.id
    #assert matchs.status == 2
    
    #対戦要求が拒否された旨を表示する
    delete logout_path
    get root_path
    login_as(@michael)
    post matchs_path, params: {user_id: @michael.id}
    follow_redirect!
    assert_not flash[:info].empty?
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs.user_id == @michael.id
    # assert matchs.opponent_id == 0
    assert matchs.status == 1
    get root_path
    get matchs_path
    assert flash.empty?
    
    #対局室から移動する
    delete match_path(@michael)
    assert_redirected_to root_path
    matchs = Match.find_by(user_id: @michael.id)
    assert matchs == nil
  end
end
