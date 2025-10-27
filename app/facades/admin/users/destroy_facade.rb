class Admin::Users::DestroyFacade < Base::Admin::DestroyFacade
  def resource
    @resource ||= User.find(@params[:id])
  end
end
