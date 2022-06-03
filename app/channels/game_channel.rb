class GameChannel < ApplicationCable::Channel
  include SessionsHelper
  include GamesHelper
  
  def subscribed
    # stream_from "some_channel"
    # current_user.appear
    user_match = Match.find_by(id: current_user.match.id)
    if (nil != user_match) and (-1 != user_match.game_id)
      game = Game.find_by(id: current_user.match.game_id)
      turn = my_turn(game)
      if (user_match.game_id) and (false == isConnected(game, turn))
        #接続時の処理
        game.connect ^= turn
        game.save
        
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
      game = Game.find_by(id: current_user.match.game_id)
      turn = my_turn(game)
      if(true == isConnected(game, turn))
        game.connect ^= turn
        game.save
        5.times {puts "*********    game.connect: #{game.connect} ***********"} #debug用
      end
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
