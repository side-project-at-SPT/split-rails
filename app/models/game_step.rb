class GameStep < ApplicationRecord
  belongs_to :game

  enum step_type: {
    initialize_map_by_system: 0,
    place_pasture: 1,
    place_stack: 2,
    split_stack: 3,
  }, _suffix: :step

  enum game_phase: {
    build_map: 0,
    place_stack: 1,
    split_stack: 2,
    game_over: 3,
    game_interrupted: 4,
  }, _suffix: :phase
end
