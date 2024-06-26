module Domain
  class GameTurnStartedEvent < Event
    def initialize(game_id: nil)
      raise 'game_id is required' if game_id.nil?

      super(game_id:)
    end

    def event_type
      'turn_started'.freeze
    end

    def dispatch
      Game.find(params[:game_id])
          .then do |game|
        GameChannel.broadcast_to(game, { event: event_type })
      end
    end
  end
end
