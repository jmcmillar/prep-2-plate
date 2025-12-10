class AuthenticatedController < ApplicationController
  include DestroyFlash

  # Devise: Require authentication for all actions
  before_action :authenticate_user!

  # Set Current.user for compatibility with existing code patterns
  before_action :set_current_user

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_current_user
    Current.user = current_user # current_user is a Devise helper
  end
end
