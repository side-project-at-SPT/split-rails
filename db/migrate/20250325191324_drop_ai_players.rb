class DropAiPlayers < ActiveRecord::Migration[7.1]
  def change
    drop_table :ai_players do |t|
      t.bigint :bot_id, null: false
      t.bigint :player_id, null: false

      t.index :bot_id
      t.index :player_id
    end
  end
end
