class Game < ApplicationRecord
  belongs_to :room

  def current_player
    players[current_player_index]
  end

  def close
    update!(is_finished: true)
  end

  def on_going?
    !is_finished
  end

  def finished?
    is_finished
  end

  def valid_position?(params)
    # TODO: implement this method
    Rails.logger.info { 'todo: implement Game#valid_position?' }
    true

    # return false unless params[:x].is_a?(Integer) && params[:y].is_a?(Integer)
    # return false unless (0..2).cover?(params[:x]) && (0..2).cover?(params[:y])

    # steps.none? { |step| step['x'] == params[:x] && step['y'] == params[:y] }
  end

  def pastures
    steps.last&.fetch('pastures', [])
  end

  def new_step(step_type, params = {})
    Step.new(self, step_type:, **params).exec
  end

  def random_place_stack
    current_player_color = players[current_player_index]['color']
    new_step(
      'place stack',
      destination_grid: {
        'x' => rand(5 + players.size),
        'y' => rand(5 + players.size),
        'stack' => {
          'color' => current_player_color
        }
      }
    )
  end

  def game_reset
    update!(
      {
        steps: [],
        current_player_index: calculate_current_player_index
      }
    )
  end

  def initialize_map_by_system
    new_step 'initialize map by system'
  end

  private

  def calculate_current_player_index
    (created_at.to_i * 13 + 17) % players.size
  end
end
