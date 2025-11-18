# app/controllers/sessions_controller.rb
class SessionsController < AuthenticatedController
  include RateLimitable

  skip_before_action :require_authentication, only: [:new, :create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.format.json? }
  before_action :check_authentication_rate_limit, only: [:create]

  layout "auth"

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Incorrect email or password"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out successfully"
  end

  private

  def check_authentication_rate_limit
    # Allow 5 login attempts per 15 minutes per IP address
    check_rate_limit(key: 'login', limit: 5, period: 15.minutes)
  end
end
