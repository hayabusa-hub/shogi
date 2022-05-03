class GameChannel < ApplicationCable::Channel
  include SessionsHelper
  include GamesHelper
  
  def subscribed
    # stream_from "some_channel"
    # current_user.appear
    user_match = Match.find_by(id: current_user.match.id)
    if nil != user_match
      if DISCONNECT == user_match.status
        #接続時の処理
        user_match.status = PLAYING
        user_match.save
        
        5.times {puts "********* reconnect ***********"} #debug用
      end
      
      5.times {puts "********* subscribed: #{current_user.name} ***********"} #debug用
      
      #購読
      stream_from "game_channel_#{current_user.match.game_id}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    #切断時の処理
    user_match = Match.find_by(id: current_user.match.id)
    if (nil != user_match) and (-1 != user_match.game_id)
      5.times {puts "********* unsubscribed user: #{current_user.name}, game_id: #{current_user.match.game_id} ***********"} #debug用
      user_match.status = DISCONNECT
      user_match.save
      
      #対戦相手へ切断したことを通知する
      gameBroadcast(current_user.match.game_id, true)
    end
  end
  
  def receive(data)
    # ActionCable.server.broadcast("game_channel", game_id: data.id)
    5.times {puts "********* broadcast again!!! ***********"} #debug用
  end
  
  def speak(data)
    # 5.times {puts "********* broadcast ***********"} #debug用
    # ActionCable.server.broadcast("game_channel", game_id: data.id)
  end
end
