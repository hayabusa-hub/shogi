class GameChannel < ApplicationCable::Channel
  include SessionsHelper
  
  def subscribed
    # stream_from "some_channel"
    stream_from "game_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def receive(data)
    ActionCable.server.broadcast("game_channel", game_id: data.id)
  end
  
  def speak(data)
    5.times {puts "********* broadcast ***********"} #debug用
    ActionCable.server.broadcast("game_channel", game_id: data.id)
  end
end
