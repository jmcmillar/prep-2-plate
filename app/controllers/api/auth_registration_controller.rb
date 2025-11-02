class Api::AuthRegistrationController < Api::BaseController
  skip_before_action :require_authentication, only: [:create]
  
  def create
    user = User.new(registration_params)
    
    if user.save
      session = user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )
      
      render json: {
        status: { 
          code: 200, 
          message: 'Signed up successfully.' 
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          token: session.id
        }
      }, status: :created
    else
      render json: {
        status: { 
          message: "User couldn't be created successfully. #{user.errors.full_messages.to_sentence}" 
        }
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
