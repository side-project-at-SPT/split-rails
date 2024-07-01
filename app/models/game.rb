class Game < ApplicationRecord
  belongs_to :room
  has_many :steps, dependent: :destroy, class_name: 'GameStep'

  FLAG_AUTO_GENERATE_MAP_BY_SYSTEM = true

  def should_initialize_map_by_system?
    FLAG_AUTO_GENERATE_MAP_BY_SYSTEM
  end

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

  def game_phase
    if steps.empty?
      'build map'
    else
      steps.last.game_phase
    end
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
    if steps.empty?
      []
    else
      steps.last.pastures
    end
  end

  def new_step(step_type, params = {})
    Step.new(self, step_type:, **params).exec
  end

  def random_place_stack
    current_player_color = players[current_player_index]['color']

    Step::Play.new(
      self, destination_grid: {
        'x' => rand(5 + players.size),
        'y' => rand(5 + players.size),
        'stack' => {
          'color' => current_player_color
        }
      }
    ).exec
  end

  def place_stack(target_x:, target_y:)
    current_player_color = players[current_player_index]['color']

    Step::Play.new(
      self, destination_grid: {
        'x' => target_x,
        'y' => target_y,
        'stack' => {
          'color' => current_player_color
        }
      }
    ).exec
  end

  def random_split_stack
    current_player_color = players[current_player_index]['color']

    original_grid = pastures.find do |pasture|
      (pasture['stack']['color'] == current_player_color) &&
        pasture['stack']['amount'].positive? &&
        !pasture['is_blocked']
    end

    # return unless original_grid

    random_amount = (original_grid.present? ? rand(1...original_grid['stack']['amount']) : 1)

    Step::Split.new(
      self, original_grid:, destination_grid: {
        'x' => rand(5 + players.size),
        'y' => rand(5 + players.size),
        'stack' => {
          'color' => current_player_color,
          'amount' => random_amount
        }
      }
    ).exec
  end

  def split_stack(
    original_x:, original_y:,
    target_x:, target_y:,
    target_amount:
  )
    current_player_color = players[current_player_index]['color']

    original_grid = pastures.find do |pasture|
      (pasture['x'] == original_x) && (pasture['y'] == original_y)
    end

    errors.add(:base, 'The pasture is not found') and return if original_grid.nil?

    if original_grid['stack']['color'] != current_player_color
      errors.add(:base, 'You can only split your own stack') and return
    end

    errors.add(:base, 'You can only split a stack in a non-blocked pasture') and return if original_grid['is_blocked']

    if original_grid['stack']['amount'] <= 1
      errors.add(:base, 'You can only split a stack with more than 1 sheep') and return
    end

    # the path between the original grid and the destination grid should be continuous
    unless continuous_path?(original_x, original_y, target_x, target_y)
      errors.add(:base, 'The path between the original grid and the destination grid should be continuous') and return
    end

    Step::Split.new(
      self,
      original_grid:,
      destination_grid: {
        'x' => target_x,
        'y' => target_y,
        'stack' => {
          'color' => current_player_color,
          'amount' => target_amount
        }
      }
    ).exec
  end

  # def reset_game
  #   # finish current game and create new game
  #   update!(is_finished: true)

  #   # create new game
  #   room.start_new_game
  # end

  def game_config
    Jbuilder.new do |json|
      json.players_number players.size
      json.players players do |player|
        json.id player['id']
        json.nickname player['nickname']
        json.color player['color']
        json.character player['character']
      end
    end.attributes!
  end

  def game_data(step: nil)
    Jbuilder.new do |json|
      json.step(step || steps.size)
      json.current_player_index current_player_index
      json.phase game_phase
      json.pastures pastures do |pasture|
        json.x pasture['x']
        json.y pasture['y']
        json.is_blocked pasture['is_blocked']
        json.stack do
          json.color pasture['stack']['color']
          json.amount pasture['stack']['amount']
        end
      end
    end.attributes!
  end

  def initialize_map_by_system
    Step::InitializeMapBySystem.new(self).exec
  end

  private

  def calculate_current_player_index
    (created_at.to_i * 13 + 17) % players.size
  end
end
