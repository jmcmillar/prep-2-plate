class Api::AuthController < Api::BaseController
  skip_before_action :require_authentication, only: [:create]
  
  def create
    user = User.find_by(email: params[:user][:email])

    # Authenticate using Devise's valid_password? method
    user = nil unless user&.valid_password?(params[:user][:password])
    
    if user
      session = user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )
      
      # Set JWT token in Authorization header
      response.headers['Authorization'] = "Bearer #{session.token}"

      render json: {
        status: {
          code: 200,
          message: 'Logged in successfully.'
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: session.token # Session token for authentication
        }
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Invalid credentials."
      }, status: :unauthorized
    end
  end
  
  def destroy
    if Current.session
      Current.session.destroy
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
