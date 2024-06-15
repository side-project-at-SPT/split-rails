class RemoveOrderFromGames < ActiveRecord::Migration[7.1]
  def up
    remove_column :games, :order
  end

  def down
    add_column :games, :order, :json, default: []
  end
end
