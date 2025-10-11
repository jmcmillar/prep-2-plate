class Admin::Users::DestroyFacade < Base::Admin::DestroyFacade
  def user
    @user ||= User.find(@params[:id])
  end
end
