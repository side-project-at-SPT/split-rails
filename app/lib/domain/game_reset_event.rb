module Domain
  class GameResetEvent < Event
    def initialize(game_id: nil)
      raise 'game_id is required' if game_id.nil?

      super(game_id:)
    end

    def event_type
      'game_reset'.freeze
    end

    def dispatch
      Game.find(params[:game_id])
          .then do |game|
        GameChannel.broadcast_to(
          game, {
            event: event_type,
            game_config: game.game_config
          }
        )
      end

      # ActionCable.server.broadcast(
      #   'lobby_channel',
      #   { event: event_type }
      # )
    end
  end
end
