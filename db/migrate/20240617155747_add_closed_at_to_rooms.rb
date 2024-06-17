class AddClosedAtToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :closed_at, :datetime
  end
end
