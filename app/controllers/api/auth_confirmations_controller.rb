# Resends the email confirmation link. Always answers the same way so it
# can't be used to check which emails have accounts.
class Api::AuthConfirmationsController < Api::BaseController
  skip_before_action :require_authentication, only: [ :create ]

  def create
    user = User.find_by(email: params.dig(:user, :email).to_s.strip.downcase)
    user.send_confirmation_instructions if user && !user.confirmed?

    render json: {
      status: 200,
      message: I18n.t("devise.confirmations.send_paranoid_instructions")
    }, status: :ok
  end
end
