class Step
  include ActiveModel::Attributes

  attribute :step_type, String # 'place pasture', 'place stack', 'split stack'
  attribute :game_data # cache game data
  attribute :previous_game_data # cache game data

  attribute :original_grid, default: { x: 0, y: 0, color: 'white', quantity: 0 }
  attribute :destination_grid

  SHEEP_INITIAL_QUANTITY = 16

  def initialize(game, step_type:, destination_grid: nil, original_grid: nil)
    @game = game
    @step_type = step_type
    @game_data = {}
    @previous_game_data = game.steps.empty? ? {} : game.steps.last
    @original_grid = original_grid
    @destination_grid = destination_grid
  end

  def exec
    case @step_type
    when 'place pasture'
      place_pasture
    when 'place stack'
      place_stack
    when 'split stack'
      split_stack
    when 'initialize map by system'
      initialize_map_by_system
      @game.steps << @game_data
      @game.save!
      return 'map initialized by system'
    end

    @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
    @game.steps << @game_data
    @game.save!
  end

  def initialize_map_by_system
    # initialize map by system
    # check if the map is already initialized
    # if yes, return error
    # if not, initialize the map
    raise 'The map is already initialized' unless @game.steps.empty?

    @game_data[:step] = @game.steps.count
    @game_data[:step_type] = 'initialize map by system'
    @game_data[:current_player_index] = @game.current_player_index
    player_size = @game.players.size
    full_map = (player_size + 5).times.map do |i|
      (player_size + 5).times.map do |j|
        { x: i, y: j, is_blocked: false, stack: { color: 'blank', amount: 0 } }
      end
    end.flatten
    @game_data[:pastures] = full_map.sample(SHEEP_INITIAL_QUANTITY * player_size)
  end

  def place_pasture
    # place pasture
    # check if the pasture is blocked
    # if not, place the pasture
    # if yes, return error
  end

  def place_stack
    # place stack
    # check if the destination_grid is captured
    # if yes, return error
    # if not, place the stack

    raise 'The map is not initialized' if @previous_game_data['pastures'].empty?

    # you can't place the stack twice in a game
    if @previous_game_data['pastures'].find do |pasture|
         pasture['stack']['color'] == @destination_grid['stack']['color']
       end
      raise "#{@destination_grid['stack']['color']} has already placed the stack"
    end

    raise 'destination_grid.stack.color is required' unless @destination_grid['stack']['color']

    target = @previous_game_data['pastures'].find do |pasture|
      pasture['x'] == @destination_grid['x'] && pasture['y'] == @destination_grid['y']
    end

    raise 'destination_grid is not found' unless target
    raise 'The pasture is already captured' unless target['stack']['amount'].zero?

    target['stack'] = {
      'color' => @destination_grid['stack']['color'],
      'amount' => SHEEP_INITIAL_QUANTITY
    }

    # write to game_data

    @game_data[:step] = @game.steps.count
    @game_data[:step_type] = 'place stack'
    @game_data[:current_player_index] = @game.current_player_index
    @game_data[:pastures] = @previous_game_data['pastures']

    @game_data[:pastures].find do |pasture|
      pasture['stack']['amount'].positive?
    end

    puts 'ready to place stack'
  end
end
