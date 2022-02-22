class GameBroadCastJob < ApplicationJob
  queue_as :default

  def perform(game)
    # Do something later
    ActionCable.server.broadcast("game_channel", game_id: game.id)
  end
end
