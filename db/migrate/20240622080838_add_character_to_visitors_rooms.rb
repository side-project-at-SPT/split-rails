class AddCharacterToVisitorsRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :visitors_rooms, :character, :string, default: 'none'
  end
end
