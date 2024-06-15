class CreateVisitorsRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :visitors_rooms do |t|
      t.belongs_to :visitor, null: false, foreign_key: true
      t.belongs_to :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
