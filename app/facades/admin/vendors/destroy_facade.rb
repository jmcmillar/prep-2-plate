class Admin::Vendors::DestroyFacade < Base::Admin::DestroyFacade
  def vendor
    @vendor ||= Vendor.find(@params[:id])
  end
end
