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
      grid_candidates = connect_grids(initial_grid)

      while pastures.size < target_grid_number
        # pop random grid from grid_candidates
        sample_grid = grid_candidates.sample
        grid_candidates.delete(sample_grid)
        next if pastures.include?(sample_grid)

        pastures << sample_grid
        grid_candidates += connect_grids(sample_grid)
      end

      # offset grids to origin (0, 0)
      # 1. find the minimum of minimum x and minimum y
      min_x = pastures.map { |g| g[:x] }.min
      min_y = pastures.map { |g| g[:y] }.min
      offset = [min_x, min_y].min

      # 2. offset the grids
      @game_data.pastures = pastures.map do |g|
        { x: g[:x] - offset, y: g[:y] - offset, is_blocked: false, stack: { color: 'blank', amount: 0 } }
      end
    end

    def connect_grids(grid)
      # is connected means that the grid is connected to the grid that shares the same edge
      # the grid is Hexagon
      # the grid coordinate is (x, y)
      # the pseudo axis is a: "x = N", b: "y = N", c: "x + y = N"

      # given the grid coordinate (x, y)
      # output the connected grid coordinate

      grids = [
        { x: grid[:x] + 1, y: grid[:y] },
        { x: grid[:x] - 1, y: grid[:y] },
        { x: grid[:x], y: grid[:y] + 1 },
        { x: grid[:x], y: grid[:y] - 1 },
        { x: grid[:x] + 1, y: grid[:y] - 1 },
        { x: grid[:x] - 1, y: grid[:y] + 1 }
      ].map { |g| { x: g[:x], y: g[:y], is_blocked: false, stack: { color: 'blank', amount: 0 } } }
    end
  end
end
