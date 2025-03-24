class GameStep < ApplicationRecord
  belongs_to :game

  enum :step_type, {
    initialize_map_by_system: 0,
    place_pasture: 1,
    place_stack: 2,
    split_stack: 3,
    game_over: 4
  }, suffix: :step

  enum :game_phase, {
    build_map: 0,
    place_stack: 1,
    split_stack: 2,
    game_over: 3,
    game_interrupted: 4
  }, suffix: :phase

  def author
    action['author'] || 'unknown'
  end

  def action_name
    action['action_name'] || 'unknown'
  end

  def to_grid
    {
      x: action.dig('to_grid', 'x'),
      y: action.dig('to_grid', 'y'),
      stack: {
        color: action.dig('to_grid', 'color'),
        amount: action.dig('to_grid', 'amount')
      }
    }
  end

  def from_grid
    {
      x: action.dig('from_grid', 'x'),
      y: action.dig('from_grid', 'y'),
      stack: {
        color: action.dig('from_grid', 'color'),
        amount: action.dig('from_grid', 'amount')
      }
    }
  end
end
