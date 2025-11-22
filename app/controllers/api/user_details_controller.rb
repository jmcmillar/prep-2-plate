class Api::UserDetailsController < Api::BaseController
  def show
  end

  def update
    if Current.user.update(user_detail_params)
      render json: {
        status: 200,
        message: "Profile updated successfully",
        data: UserSerializer.new(Current.user).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        errors: Current.user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def user_detail_params
    params.require(:user).permit(:first_name, :last_name, :email, :image)
  end
end
