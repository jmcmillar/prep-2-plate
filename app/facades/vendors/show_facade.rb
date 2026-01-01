class Vendors::ShowFacade < BaseFacade
  def menu
    :main_menu
  end

  def active_key
    :vendors
  end

  def nav_resource
    nil
  end

  def vendor
    @vendor ||= Vendor.active.find(@params[:id])
  end

  def offerings
    @offerings ||= vendor.offerings.order(created_at: :desc)
  end
end
