class ApplicationController < ActionController::Base
  include DestroyFlash
  include Pagy::Frontend

  # Set Current.user for all controllers (both authenticated and public)
  before_action :set_current_user

  # Devise: Configure permitted parameters for sign up and account update
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def set_current_user
    Current.user = current_user if user_signed_in?
  end

  def configure_permitted_parameters
    # Permit first_name and last_name for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # Permit first_name, last_name, and image for account updates
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :image])
  end
end
