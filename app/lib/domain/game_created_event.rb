module Domain
  class GameCreatedEvent < Event
    def initialize(game_id: nil, new_game_id: nil)
      raise 'game_id is required' if game_id.nil?
      raise 'new_game_id is required' if new_game_id.nil?

      super(game_id:, new_game_id:)
    end

    def event_type
      'game_created'.freeze
    end

    def dispatch
      Game.find(params[:game_id])
          .then do |game|
        GameChannel.broadcast_to(
          game, {
            event: event_type,
            game_id: params[:new_game_id]
          }
        )
      end
    end
  end
end
