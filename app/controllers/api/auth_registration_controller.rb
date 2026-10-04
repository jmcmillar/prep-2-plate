class Api::AuthRegistrationController < Api::BaseController
  skip_before_action :require_authentication, only: [ :create ]

  def create
    user = User.new(registration_params)

    if user.save
      # Start new accounts with a list so recipes can be added right away
      user.shopping_lists.create!(name: "My List", current: true)

      # No session until the email is confirmed; Devise sends the confirmation email
      render json: {
        status: {
          code: 201,
          message: I18n.t("devise.registrations.signed_up_but_unconfirmed")
        },
        data: {
          user: UserSerializer.new(user).serializable_hash[:data][:attributes],
          confirmationRequired: true
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
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
end
