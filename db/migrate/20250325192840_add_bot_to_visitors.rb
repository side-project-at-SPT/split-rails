class AddBotToVisitors < ActiveRecord::Migration[7.1]
  def change
    add_reference :visitors, :bot, null: true, foreign_key: true
  end
end
