class ApplicationController < ActionController::Base
  FIRST = 1
  SECOND = 2
  X = ["9", "8", "7", "6", "5", "4", "3", "2", "1"]
  Y = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
  ORDER= [0, 1, 2, 3, 4, 5, 6, 7, 8]
  
  STANDBY = 0 #対戦待ち
  WAITING = 1 #対戦要求中
  DECLINE = 2
  PLAYING = 3 #ゲーム中
end
