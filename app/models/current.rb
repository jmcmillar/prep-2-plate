class Current < ActiveSupport::CurrentAttributes
  attribute :session  # For API authentication (custom Session model)
  attribute :user     # For web authentication (Devise)
end
