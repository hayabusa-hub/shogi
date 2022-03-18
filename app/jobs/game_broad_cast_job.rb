class GameBroadCastJob < ApplicationJob
  queue_as :default

  def perform(game)
    # Do something later
    5.times {puts "********* broadcast in job ***********"} #debug用
    ActionCable.server.broadcast("game_channel", game_id: game.id)
  end
end
