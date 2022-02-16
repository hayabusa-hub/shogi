class MatchChannel < ApplicationCable::Channel
  
  include SessionsHelper
  
  def subscribed
    # stream_from "some_channel"
    stream_from "match_channel"
    #5.times {puts "*********test***********"}
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # def speak(data)
  #   ActionCable.server.broadcast('match_channel', message: data['message'])
  # end
end
