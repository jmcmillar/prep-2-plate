class Api::UserDetailsController < Api::BaseController
  def show
  end

  def update
    Current.user.assign_attributes(user_detail_params)

    if Current.user.save
      render json: "successful", status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def user_detail_params
    params.require(:user).permit(:first_name, :last_name, :email, :image)
  end
end
