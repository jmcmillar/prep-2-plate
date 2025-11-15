class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :notifications, :boolean, default: false, null: false
    add_column :users, :reminders, :boolean, default: false, null: false
  end
end
