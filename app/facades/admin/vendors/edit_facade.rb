class Admin::Vendors::EditFacade < Base::Admin::EditFacade
  def vendor
    @vendor ||= Vendor.find(@params[:id])
  end

  def active_key
    :admin_vendors
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new(vendor.business_name, [:admin, vendor]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, vendor]
  end

  def status_options
    [
      OpenStruct.new(id: "active", name: "Active"),
      OpenStruct.new(id: "inactive", name: "Inactive")
    ]
  end
end
