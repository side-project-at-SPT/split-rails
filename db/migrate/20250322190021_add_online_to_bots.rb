class AddOnlineToBots < ActiveRecord::Migration[7.1]
  def change
    add_column :bots, :status, :string, default: 'offline', null: false
  end
end
