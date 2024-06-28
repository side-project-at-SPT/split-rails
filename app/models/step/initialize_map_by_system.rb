module Step
  class InitializeMapBySystem < BaseStep
    def initialize(game, params = {})
      super(game, step_type: 'initialize map by system', **params)
    end

    def exec
      initialize_map_by_system

      super
    end

    def initialize_map_by_system
      errors.add(:base, 'The map is already initialized') and return unless @game.game_phase == 'build map'

      @game_data[:step] = @game.steps.count
      @game_data[:step_type] = 'initialize map by system'
      @game_data[:current_player_index] = @game.current_player_index
      player_size = @game.players.size
      # 2: 32 -> 6 * 6
      # 3: 48 -> 7 * 7
      # 4: 64 -> 8 * 8
      offset = player_size + 4

      full_map = (offset).times.map do |i|
        (offset).times.map do |j|
          { x: i, y: j, is_blocked: false, stack: { color: 'blank', amount: 0 } }
        end
      end.flatten
      @game_data[:pastures] = full_map.sample(SHEEP_INITIAL_QUANTITY * player_size)
      @game_data[:phase] = 'place stack'
    end
  end
end
