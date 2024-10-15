class CreateBots < ActiveRecord::Migration[7.1]
  def change
    create_table :bots do |t|
      t.string :name, null: false
      t.belongs_to :visitor, null: false, foreign_key: true
      t.string :webhook_url, null: false
      t.integer :concurrent_number, null: false, default: 1

      t.timestamps
    end
  end
end
