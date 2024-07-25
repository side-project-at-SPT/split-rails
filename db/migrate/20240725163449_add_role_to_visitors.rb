class AddRoleToVisitors < ActiveRecord::Migration[7.1]
  def change
    add_column :visitors, :role, :integer, null: false, default: 2 # ENUM: 0 - admin, 1 - user, 2 - guest
  end
end
