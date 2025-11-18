class AddSecurityFieldsToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :token, :string
    add_index :sessions, :token, unique: true
    add_column :sessions, :expires_at, :datetime
    add_column :sessions, :last_used_at, :datetime
  end
end
