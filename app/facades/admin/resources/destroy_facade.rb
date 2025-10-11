class Admin::Resources::DestroyFacade < Base::Admin::DestroyFacade
  def resource
    @resource ||= Resource.find(@params[:id])
  end
end
