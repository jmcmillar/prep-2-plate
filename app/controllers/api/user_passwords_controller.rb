class Api::UserPasswordsController < Api::BaseController
  def show
  end

  def update
    if Current.user.update_with_password(user_password_params)
      render json: { message: "Password updated successfully" }, status: :created
      bypass_sign_in(Current.user)
    else
      render json: Current.user.errors, status: :unprocessable_entity
    end
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
