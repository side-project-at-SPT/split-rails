class Game < ApplicationRecord
  belongs_to :room

  def current_player
    players[current_player_index]
  end

  def close
    update!(is_finished: true)
  end
end
