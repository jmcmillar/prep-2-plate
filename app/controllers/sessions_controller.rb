# app/controllers/sessions_controller.rb
class SessionsController < AuthenticatedController
  skip_before_action :require_authentication, only: [:new, :create, :destroy]
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
end
