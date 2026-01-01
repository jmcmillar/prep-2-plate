class Admin::Offerings::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_offerings
  end

  def base_collection
    scope = Offering.includes(:vendor, :meal_types).where(vendor_id: vendor.id).order(created_at: :desc)
    Base::AdminPolicy::Scope.new(@user, scope).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new(vendor.business_name, [:admin, vendor]),
      BreadcrumbComponent::Data.new("Offerings")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, vendor, :offerings],
      query: collection.search_collection,
      label: "Search Offering Name",
      field: :name_cont
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, vendor, :offering],
      :plus,
      "New Offering"
    ]
  end

  def resource_facade_class
    Admin::Offerings::ResourceFacade
  end

  def vendor
    @vendor ||= Vendor.find(@params[:vendor_id])
  end

  def menu
    :admin_vendor_menu
  end

  def nav_resource
    vendor
  end

  def active_key
    :admin_offerings
  end
end
