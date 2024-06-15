class UpdateColumnCurrentPlayerOnGames < ActiveRecord::Migration[7.1]
  def up
    remove_column :games, :current_player
    add_column :games, :current_player_index, :integer, default: 0
  end

  def down
    remove_column :games, :current_player_index
    add_column :games, :current_player, :string
  end
end
