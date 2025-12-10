class ConfirmExistingUsers < ActiveRecord::Migration[8.0]
  def up
    # Auto-confirm all existing users so they can log in immediately
    User.update_all(confirmed_at: Time.current)
  end

  def down
    # Don't un-confirm users on rollback
    # This is intentionally left empty
  end
end
