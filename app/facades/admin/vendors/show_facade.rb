class Admin::Vendors::ShowFacade < Base::Admin::ShowFacade
  def vendor
    @vendor ||= Vendor.find(@params[:id])
  end

  def menu
    :admin_vendor_menu
  end

  def nav_resource
    vendor
  end

  def active_key
    :admin_vendor
  end


  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new(vendor.business_name)
    ]
  end

  def header_actions
    [edit_action_data, new_offering_data]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, vendor],
      :edit,
      "Edit Vendor"
    ]
  end

  def new_offering_data
    IconLinkComponent::Data[
      [:new, :admin, vendor, :offering],
      :plus,
      "New Offering"
    ]
  end

  def offerings
    @offerings ||= vendor.offerings.order(created_at: :desc).limit(10)
  end

  def status_badge
    scheme = vendor.active? ? :success : :default
    BadgeComponent::Data.new(text: vendor.status.titleize, scheme: scheme)
  end
end
