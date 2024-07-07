module Step
  class InitializeMapBySystem < BaseStep
    def initialize(game, params = {})
      super(game, step_type: 'initialize_map_by_system', **params)
    end

    def exec
      initialize_map_by_system

      super
    end

    DROP_GRID_FROM_SQUARE_GRIDS = 1
    SIMPLY_RANDOMLY_PLACE_GRID = 2

    def initialize_map_by_system
      errors.add(:base, 'The map is already initialized') and return unless @game.game_phase == 'build map'

      flag_map_generate_strategy = $redis.get('flag_map_generate_strategy') || SIMPLY_RANDOMLY_PLACE_GRID
      case flag_map_generate_strategy.to_i
      when DROP_GRID_FROM_SQUARE_GRIDS
        generate_map_by_drop_grid_of_square_grids
      when SIMPLY_RANDOMLY_PLACE_GRID
        generate_map_by_randomly_place_grid
      else raise 'Invalid counter'
      end

      @game_data.current_player_index = @game.current_player_index
      @game_data.step_number = @game.steps.size + 1
      @game_data.game_phase = 'place_stack'
    end

    def generate_map_by_drop_grid_of_square_grids
      player_size = @game.players.size
      # 2: 32 -> 6 * 6
      # 3: 48 -> 7 * 7
      # 4: 64 -> 8 * 8
      offset = player_size + 4

      full_map = offset.times.map do |i|
        offset.times.map do |j|
          { x: i, y: j, is_blocked: false, stack: { color: 'blank', amount: 0 } }
        end
      end.flatten
      @game_data.pastures = full_map.sample(SHEEP_INITIAL_QUANTITY * player_size)
    end

    def generate_map_by_randomly_place_grid
      target_grid_number = @game.players.size * 16
      initial_grid = { x: 10, y: 10, is_blocked: false, stack: { color: 'blank', amount: 0 } }
      pastures = [initial_grid]
      grid_candidates = Domain::Common.connect_grids(initial_grid)

      while pastures.size < target_grid_number
        # pop random grid from grid_candidates
        sample_grid = grid_candidates.sample
        grid_candidates.delete(sample_grid)
        next if pastures.include?(sample_grid)

        pastures << sample_grid
        grid_candidates += Domain::Common.connect_grids(sample_grid)
      end

      # try to move the map to the top left corner
      # 1. find the offset_x and offset_y
      offset_x = pastures.map { |g| g[:x] }.min
      offset_y = pastures.map { |g| g[:y] }.min

      # 2. offset the grids
      @game_data.pastures = pastures.map do |g|
        g[:x] -= offset_x
        g[:y] -= offset_y
        g
      end
    end
  end
end
