module Step
  class BaseStep
    include ActiveModel::Attributes
    extend ActiveModel::Naming

    attribute :step_type, String # 'place pasture', 'place stack', 'split stack'
    attribute :game_data # cache game data
    # attribute :previous_game_data # cache game data
    attribute :previous_pastures # cache pastures

    attribute :original_grid, default: { x: 0, y: 0, color: 'white', quantity: 0 }
    attribute :destination_grid

    SHEEP_INITIAL_QUANTITY = 16

    def initialize(game, step_type:, destination_grid: nil, original_grid: nil)
      @errors = ActiveModel::Errors.new(self)

      @game = game
      @step_type = step_type
      @game_data = {}
      # @previous_game_data = game.steps.empty? ? {} : game.steps.last
      @previous_pastures = game.pastures
      @original_grid = original_grid
      @destination_grid = destination_grid
    end

    attr_reader :errors

    def exec
      if @errors.any?
        Rails.logger.error "step_type: #{@step_type} failed"
        return self
      end

      case @step_type
      when 'place pasture', 'place stack', 'split stack'
        @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
      when 'initialize map by system'
        # do nothing
      else
        raise 'Invalid step type'
      end

      @game.steps << @game_data
      @game.save!

      Rails.logger.info { "step_type: #{@step_type} executed" }

      self
    end

    def place_pasture
      # place pasture
      # check if the pasture is blocked
      # if not, place the pasture
      # if yes, return error
    end
  end
end