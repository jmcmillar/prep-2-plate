class Api::UserNotificationsController < Api::BaseController
  def show
    @user = Current.user
  end

  def update
    user = Current.user
    if user.update(user_notifications_params)
      render json: {reminders: user.reminders, notifications: user.notifications}, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_notifications_params
    params.require(:user_notification).permit(:notifications, :reminders)
  end
end
