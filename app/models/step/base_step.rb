module Step
  class BaseStep
    include ActiveModel::Attributes
    extend ActiveModel::Naming

    attribute :step_type, String # 'place pasture', 'place stack', 'split stack'
    attribute :game_data # cache game data
    attribute :previous_pastures # cache pastures

    attribute :original_grid, default: { x: 0, y: 0, color: 'white', quantity: 0 }
    attribute :destination_grid

    SHEEP_INITIAL_QUANTITY = 16

    def initialize(game, step_type:, destination_grid: nil, original_grid: nil)
      @errors = ActiveModel::Errors.new(self)

      @game = game
      @step_type = step_type
      @game_data = GameStep.new(game:, step_type:)
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

      flag_on_going = true

      memo_current_player_index = @game.current_player_index

      case @game_data.game_phase
      when 'initialize_map_by_system', 'build map'
        # do nothing
      when 'place_pasture', 'place_stack'
        next_player_index = (memo_current_player_index + 1) % @game.players.size
      when 'split_stack'
        next_player_index = Domain::Common.next_available_player_index(
          current_player_index: memo_current_player_index,
          colors: @game.players.map { |player| player['color'] },
          pastures: @previous_pastures
        )
        # if next_player_index == -1, no player can play, game over
        # if next_player_index == memo_current_player_index, need to check if current player occupied maximum pastures
        if next_player_index == -1 || (
          next_player_index == memo_current_player_index && (
            # there is only 1 player has the maximum pastures
            @previous_pastures.map do |pasture|
              pasture['stack']['color'] == 'blank' ? nil : pasture['stack']['color']
            end.compact.tally.group_by(&:last).max_by(&:first).last.size == 1
          )
        )
          flag_on_going = false
        end
      else
        Rails.logger.error "Invalid game phase: #{@game.game_phase}"
        raise 'Invalid game phase'
      end

      unless next_player_index == -1
        @game.current_player_index = next_player_index
        @game_data.current_player_index = next_player_index
      end

      @game.steps << @game_data
      Rails.logger.info { "step_type: #{@step_type} executed" }

      game_over = !flag_on_going
      if game_over
        game_over_step = GameStep.new(
          game: @game,
          step_number: @game_data.step_number + 1,
          step_type: 'game_over',
          current_player_index: @game.current_player_index,
          pastures: @previous_pastures,
          game_phase: 'game_over',
          action: {
            author: 'system',
            action_name: 'game_over'
          }
        )
        @game.steps << game_over_step
        Rails.logger.info { 'game_over_step executed' }
      end
      @game.save!

      self
    end

    def place_pasture
      raise 'Not implemented'
      # place pasture
      # check if the pasture is blocked
      # if not, place the pasture
      # if yes, return error
    end
  end
end
