# https://github.com/side-project-at-SPT/split-rails/issues/15
class AddOwnerToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :owner_id, :integer
  end
end
