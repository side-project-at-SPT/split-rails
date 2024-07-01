class CreateGameSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :game_steps do |t|
      t.belongs_to :game, null: false, foreign_key: true
      t.integer :step_number, null: false
      t.integer :step_type, null: false
      t.integer :current_player_index, null: false
      t.json :pastures, default: []
      t.integer :game_phase, null: false

      t.timestamps
    end
  end
end
