class RemoveStepsFromGames < ActiveRecord::Migration[7.1]
  def up
    remove_column :games, :steps
  end

  def down
    add_column :games, :steps, :json, default: []
  end
end
