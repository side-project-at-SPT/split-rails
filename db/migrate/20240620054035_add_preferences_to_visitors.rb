class AddPreferencesToVisitors < ActiveRecord::Migration[7.1]
  def change
    add_column :visitors, :preferences, :json
  end
end
