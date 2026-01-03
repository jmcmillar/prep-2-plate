# Configure Blazer to use admin authentication
# This ensures only admin users can access Blazer
Rails.application.config.to_prepare do
  Blazer::BaseController.class_eval do
    before_action :authenticate_user!
    before_action :require_admin

    private

    def require_admin
      return if current_user&.admin?

      Rails.logger.info "BLAZER AUTH: Non-admin user #{current_user&.id} attempted to access Blazer - redirecting to root"
      flash[:alert] = "You are not authorized to access this page."
      redirect_to("/") and return
    end
  end
end

