module Step
  class Split < BaseStep
    def initialize(game, params = {})
      super(game, step_type: 'split stack', **params)
    end

    def exec
      split_stack

      super
    end

    def split_stack
      errors.add(:game, 'The map is not initialized') and return if @game.game_phase == 'build map'

      # you can only split your own stack
      unless @original_grid['stack']['color'] == @game.players[@game.current_player_index]['color']
        # raise 'You can only split your own stack'
        errors.add(:original_grid, 'You can only split your own stack') and return
      end

      # you can only split a stack in a non-blocked pasture
      unless @original_grid['is_blocked'] == false
        # raise 'You can only split a stack in a non-blocked pasture'
        errors.add(:original_grid, 'You can only split a stack in a non-blocked pasture') and return
      end

      # you can only split a stack with more than 1 sheep
      unless @original_grid['stack']['amount'] > 1
        # raise 'You can only split a stack with more than 1 sheep'
        errors.add(:original_grid, 'You can only split a stack with more than 1 sheep') and return
      end

      # the path between the original grid and the destination grid should be continuous
      unless continuous_path?
        # raise 'The path between the original grid and the destination grid should be continuous' unless continuous_path?
        errors.add(:original_grid,
                   'The path between the original grid and the destination grid should be continuous') and return
      end

      target = @previous_pastures.find do |pasture|
        pasture['x'] == @destination_grid['x'] && pasture['y'] == @destination_grid['y']
      end

      # the destination grid should be exist
      unless target
        # raise 'The pasture is not found' unless target
        errors.add(:destination_grid, 'The pasture is not found') and return
      end

      # the destination grid should be empty
      unless target['stack']['amount'].zero?
        # raise 'The pasture is already captured' unless target['stack']['amount'].zero?
        errors.add(:destination_grid, 'The pasture is already captured') and return
      end

      # at least one sheep should be left in the original grid
      unless (@original_grid['stack']['amount'] - @destination_grid['stack']['amount']).positive?
        # raise 'At least one sheep should be left in the original grid'
        errors.add(:original_grid, 'At least one sheep should be left in the original grid') and return
      end

      # split the stack

      @original_grid['stack']['amount'] -= @destination_grid['stack']['amount']

      target['stack'] = {
        'color' => @destination_grid['stack']['color'],
        'amount' => @destination_grid['stack']['amount']
      }
      target['is_blocked'] = check_blocked?(target, @previous_pastures)

      # write to game_data

      @game_data[:step] = @game.steps.count
      @game_data[:step_type] = 'split stack'
      @game_data[:current_player_index] = @game.current_player_index
      @game_data[:pastures] = @previous_pastures
      @game_data[:phase] = 'split stack'
    end

    private

    def continuous_path?
      true
    end

    def check_blocked?(target, pastures)
      false
    end
  end
end
