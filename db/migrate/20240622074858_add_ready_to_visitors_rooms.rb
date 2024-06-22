class AddReadyToVisitorsRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :visitors_rooms, :ready, :boolean, default: false
  end
end
