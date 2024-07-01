class AddActionToGameSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :game_steps, :action, :json, default: {}
  end
end
