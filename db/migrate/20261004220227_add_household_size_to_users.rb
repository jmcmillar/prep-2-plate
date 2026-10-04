class AddHouseholdSizeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :household_size, :integer
  end
end
