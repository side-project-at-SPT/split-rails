module Step
  class Split < BaseStep
    def initialize(game, params = {})
      super(game, step_type: 'split_stack', **params)
    end

    def exec
      split_stack

      super
    end

    def split_stack
      @game_data.action = {
        author: @game.players[@game.current_player_index]['color'],
        action_name: 'split_stack',
        to_grid: {
          x: @destination_grid['x'],
          y: @destination_grid['y'],
          stack: {
            color: @destination_grid['stack']['color'],
            amount: @destination_grid['stack']['amount']
          }
        },
        from_grid: {
          x: @original_grid['x'],
          y: @original_grid['y'],
          stack: {
            color: @original_grid['stack']['color'],
            amount: @original_grid['stack']['amount']
          }
        }
      }

      errors.add(:base, 'The map is not initialized') and return if @game.game_phase == 'build map'

      original_grid = @previous_pastures.find do |pasture|
        pasture['x'] == @original_grid['x'] && pasture['y'] == @original_grid['y']
      end

      # the original grid should be exist
      errors.add(:base, 'The original pasture is not found') and return unless original_grid

      # you can only split your own stack
      unless original_grid['stack']['color'] == @game.players[@game.current_player_index]['color']
        errors.add(:base, 'You can only split your own stack') and return
      end

      # you can only split a stack in a non-blocked pasture
      unless original_grid['is_blocked'] == false
        errors.add(:base, 'You can only split a stack in a non-blocked pasture') and return
      end

      # you can only split a stack with more than 1 sheep
      unless original_grid['stack']['amount'] > 1
        errors.add(:base, 'You can only split a stack with more than 1 sheep') and return
      end

      # TODO: implement continuous_path?
      # the path between the original grid and the destination grid should be continuous
      unless continuous_path?
        # raise 'The path between the original grid and the destination grid should be continuous' unless continuous_path?
        errors.add(:base,
                   'The path between the original grid and the destination grid should be continuous') and return
      end

      target = @previous_pastures.find do |pasture|
        pasture['x'] == @destination_grid['x'] && pasture['y'] == @destination_grid['y']
      end

      # the destination grid should be exist
      unless target
        # raise 'The pasture is not found' unless target
        errors.add(:base, 'The destination pasture is not found') and return
      end

      # the destination grid should be empty
      unless target['stack']['amount'].zero?
        # raise 'The pasture is already captured' unless target['stack']['amount'].zero?
        errors.add(:base, 'The pasture is already captured') and return
      end

      # at least one sheep should be left in the original grid
      unless (original_grid['stack']['amount'] - @destination_grid['stack']['amount']).positive?
        # raise 'At least one sheep should be left in the original grid'
        errors.add(:base, 'At least one sheep should be left in the original grid') and return
      end

      # split the stack

      target['stack'] = {
        'color' => @destination_grid['stack']['color'],
        'amount' => @destination_grid['stack']['amount']
      }

      Domain::Common.grid_and_its_neighbors_on_the_map(target, @previous_pastures).each do |grid|
        grid['is_blocked'] = (
          grid['is_blocked'] ||
          grid['stack']['amount'] == 1 || Domain::Common.grid_and_its_neighbors_on_the_map(grid, @previous_pastures).all? do |g|
            g['stack']['amount'].positive?
          end)
      end

      original_grid['stack']['amount'] -= target['stack']['amount']
      original_grid['is_blocked'] = true if original_grid['stack']['amount'] == 1

      # write to game_data

      @game_data.step_number = @game.steps.last.step_number + 1
      @game_data.current_player_index = @game.current_player_index
      @game_data.pastures = @previous_pastures
      @game_data.game_phase = 'split_stack'
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
