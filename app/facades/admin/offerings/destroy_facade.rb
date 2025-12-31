class Admin::Offerings::DestroyFacade < Base::Admin::DestroyFacade
  def offering
    @offering ||= Offering.find(@params[:id])
  end
end
