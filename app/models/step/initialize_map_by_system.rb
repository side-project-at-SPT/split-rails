module Step
  class InitializeMapBySystem < BaseStep
    def initialize(game, params = {})
      @seed = params[:seed]
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

      srand(@seed) if @seed

      flag_map_generate_strategy = $redis.get('flag_map_generate_strategy') || SIMPLY_RANDOMLY_PLACE_GRID
      case flag_map_generate_strategy.to_i
      when DROP_GRID_FROM_SQUARE_GRIDS
        generate_map_by_drop_grid_of_square_grids(players_number: @game.players.size)
      when SIMPLY_RANDOMLY_PLACE_GRID
        @game_data.pastures = generate_map_by_randomly_place_grid(players_number: @game.players.size)
      else raise 'Invalid counter'
      end

      @game_data.current_player_index = @game.current_player_index
      @game_data.step_number = @game.steps.size + 1
      @game_data.game_phase = 'place_stack'
    end

    def generate_map_by_drop_grid_of_square_grids(players_number: 2)
      # 2: 32 -> 6 * 6
      # 3: 48 -> 7 * 7
      # 4: 64 -> 8 * 8
      offset = players_number + 4

      full_map = offset.times.map do |i|
        offset.times.map do |j|
          { x: i, y: j, is_blocked: false, stack: { color: 'blank', amount: 0 } }
        end
      end.flatten
      @game_data.pastures = full_map.sample(SHEEP_INITIAL_QUANTITY * players_number)
    end

    def generate_map_by_randomly_place_grid(players_number: 2)
      target_grid_number = SHEEP_INITIAL_QUANTITY * players_number
      coordinates = generate_random_continuously_coordinate(number: target_grid_number)
      coordinates.map do |g|
        {
          x: g[:x],
          y: g[:y],
          is_blocked: false,
          stack: { color: 'blank', amount: 0 }
        }
      end
    end

    private

    def generate_random_continuously_coordinate(number: 32)
      initial_coordinate = { x: 100, y: 100 }
      current_coordinates = Set.new([initial_coordinate])
      candidate_coordinates = Domain::Common.connect_coordinates(
        coord_x: initial_coordinate[:x],
        coord_y: initial_coordinate[:y]
      )

      while current_coordinates.size < number
        sample_coordinate = candidate_coordinates.sample
        candidate_coordinates.delete(sample_coordinate)
        next if current_coordinates.include?(sample_coordinate)

        current_coordinates << sample_coordinate
        candidate_coordinates += Domain::Common.connect_coordinates(
          coord_x: sample_coordinate[:x],
          coord_y: sample_coordinate[:y]
        )
      end

      # try to move the map to the top left corner
      # 1. find the offset_x and offset_y
      offset_x = current_coordinates.map { |g| g[:x] }.min
      offset_y = current_coordinates.map { |g| g[:y] }.min

      # 2. offset the grids
      current_coordinates.each do |g|
        g[:x] -= offset_x
        g[:y] -= offset_y
      end

      current_coordinates
    end
  end
end
