class MigrateExistingSessions < ActiveRecord::Migration[8.0]
  def up
    # Generate tokens for existing sessions and set expiration
    Session.find_each do |session|
      # Generate a unique token
      loop do
        token = SecureRandom.urlsafe_base64(32)
        unless Session.exists?(token: token)
          session.update_columns(
            token: token,
            expires_at: 2.weeks.from_now,
            last_used_at: session.updated_at
          )
          break
        end
      end
    end
  end

  def down
    # Remove tokens and expiration data
    Session.update_all(token: nil, expires_at: nil, last_used_at: nil)
  end
end
