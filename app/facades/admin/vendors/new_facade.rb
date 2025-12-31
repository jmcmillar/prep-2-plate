class Admin::Vendors::NewFacade < Base::Admin::NewFacade
  def vendor
    @vendor ||= Vendor.new
  end

  def active_key
    :admin_vendors
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def form_url
    [:admin, :vendors]
  end

  def status_options
    [
      OpenStruct.new(id: "active", name: "Active"),
      OpenStruct.new(id: "inactive", name: "Inactive")
    ]
  end
end
