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
      is_ai = @game.players[@game.current_player_index]['role'] == 'ai'

      # generate the animation event
      animation_event_params = {}

      if is_ai
        animation_event_params = {
          player: @game.players[@game.current_player_index],
          from_x: @original_grid['x'],
          from_y: @original_grid['y'],
          to_x: @destination_grid['x'],
          to_y: @destination_grid['y']
        }
      end

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
      if original_grid['is_blocked'] == true
        Rails.logger.warn { "Origin pasture is blocked: #{original_grid}" }
        # show the neighbor pastures for debugging
        [[0, 1], [1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1]].each do |dx, dy|
          neighbor = @previous_pastures.find do |pasture|
            pasture['x'] == original_grid['x'] + dx && pasture['y'] == original_grid['y'] + dy
          end
          Rails.logger.warn { "Neighbor pasture: #{neighbor}" } if neighbor
        end
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

      # grabs the target grid and its neighbors
      grids_to_check = Domain::Common.grid_and_its_neighbors_on_the_map(target, @previous_pastures)
      @previous_pastures
        # checks if the grid is exist in the map
        .select { |g| grids_to_check.any? { |gtc| g['x'] == gtc['x'] && g['y'] == gtc['y'] } }
        # checks if the grid is blocked
        .each do |grid|
        grid['is_blocked'] = (
          # if the grid is not blank AND
          grid['stack']['color'] != 'blank' && (
            # if the grid is already blocked
            grid['is_blocked'] ||
            # if the grid has only one sheep
            grid['stack']['amount'] == 1 ||
            #  and all of its neighbors are captured
            Domain::Common.all_neighbors_capture?(grid, @previous_pastures)
          )
        )
      end

      original_grid['stack']['amount'] -= target['stack']['amount']
      original_grid['is_blocked'] = true if original_grid['stack']['amount'] == 1

      if @previous_pastures.any? { |g| g['is_blocked'] }
        Rails.logger.info { 'The following pastures are blocked' }
        Rails.logger.info { @previous_pastures.select { |g| g['is_blocked'] }.map { |g| [g['x'], g['y']] } }
      end

      # write to game_data
      generate_animation_event(**animation_event_params) if is_ai

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

    def generate_animation_event(player:, from_x:, from_y:, to_x:, to_y:)
      custom_event_type = 'move_sheep'.freeze
      GameChannel.broadcast_to(
        @game,
        {
          type: custom_event_type,
          actionPlayer: player['id'],
          character: player['character'],
          direction: 'go',
          from: { x: from_x, y: from_y },
          to: { x: to_x, y: to_y }
        }
      )
    end
  end
end
