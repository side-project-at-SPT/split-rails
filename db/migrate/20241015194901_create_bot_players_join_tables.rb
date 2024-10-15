class CreateBotPlayersJoinTables < ActiveRecord::Migration[7.1]
  def change
    create_join_table :bots, :players, table_name: :ai_players do |t|
      t.index :bot_id
      t.index :player_id
    end
  end
end
