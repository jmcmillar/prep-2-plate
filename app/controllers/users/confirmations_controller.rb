# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "auth"

  # GET /users/confirmation?confirmation_token=abcdef
  # Confirms the email, then hands off to the app to log in. A link opened
  # twice is treated as success, since the account is confirmed either way.
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty? || already_confirmed?
      @app_url = "prep2plate://sign-in?#{{ confirmed: 1, email: resource.email }.to_query}"
      render :confirmed
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def already_confirmed?
    resource.persisted? && resource.confirmed? && resource.errors.of_kind?(:email, :already_confirmed)
  end
end
