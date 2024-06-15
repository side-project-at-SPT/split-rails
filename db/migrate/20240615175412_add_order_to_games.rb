class AddOrderToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :order, :json, default: []
  end
end
