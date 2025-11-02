class Current < ActiveSupport::CurrentAttributes
  attribute :session
    # Add this method to automatically set the user from the session
  def user
    session&.user
  end
end
