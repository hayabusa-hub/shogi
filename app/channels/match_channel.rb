class MatchChannel < ApplicationCable::Channel
  
  include SessionsHelper
  
  def subscribed
    # stream_from "some_channel"
    stream_from "match_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak()
    ActionCable.server.broadcast('match_channel')
    
    #redirect_to Match.find_by(user_id: current_user().id)
  end
end
