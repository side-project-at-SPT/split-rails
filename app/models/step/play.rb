module Step
  class Play < BaseStep
    def initialize(game, params = {})
      super(game, step_type: 'place_stack', **params)
    end

    def exec
      place_stack

      super
    end

    def place_stack
      # rewrite following raise conditions to use errors.add

      if @game.game_phase == 'build map'
        # raise 'The map is not initialized' if @game.game_phase == 'build map'
        errors.add(:base, 'The map is not initialized') and return
      end

      # you can't place the stack twice in a game
      if @previous_pastures.find do |pasture|
           pasture['stack']['color'] == @destination_grid['stack']['color']
         end
        errors.add(:base, 'The stack is already placed') and return
        # raise "#{@destination_grid['stack']['color']} has already placed the stack"
      end

      unless @destination_grid['stack']['color']
        # raise 'destination_grid.stack.color is required'
        errors.add(:base, 'destination_grid.stack.color is required') and return
      end

      target = @previous_pastures.find do |pasture|
        pasture['x'] == @destination_grid['x'] && pasture['y'] == @destination_grid['y']
      end

      errors.add(:base, 'Pasture is not found') and return unless target

      # raise 'The pasture is already captured' unless target['stack']['amount'].zero?
      errors.add(:base, 'Pasture is already captured') and return unless target['stack']['amount'].zero?

      target['stack'] = {
        'color' => @destination_grid['stack']['color'],
        'amount' => SHEEP_INITIAL_QUANTITY
      }

      # write to game_data

      # @game_data[:step] = @game.steps.count
      @game_data.step_number = @game.steps.last.step_number + 1
      # @game_data[:step_type] = 'place stack'
      # @game_data[:current_player_index] = @game.current_player_index
      @game_data.current_player_index = @game.current_player_index
      @game_data.pastures = @previous_pastures

      # if all players placed the stack, move to split stack phase
      if @game_data.pastures.count { |pasture| pasture['stack']['amount'].positive? } == @game.players.size
        @game_data.game_phase = 'split_stack'
      else
        @game_data.game_phase = 'place_stack'
      end
    end
  end
end
