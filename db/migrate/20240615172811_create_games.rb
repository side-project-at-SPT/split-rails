class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.belongs_to :room, null: true
      t.boolean :is_finished, default: false
      t.json :players, default: []
      t.string :current_player
      t.json :steps, default: []

      t.timestamps
    end
  end
end
