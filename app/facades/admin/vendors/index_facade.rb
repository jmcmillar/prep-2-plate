class Admin::Vendors::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_vendors
  end

  def base_collection
    Base::AdminPolicy::Scope.new(
      @user,
      Vendor.order(created_at: :desc)
    ).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :vendors],
      query: collection.search_collection,
      label: "Search Business Name, Contact",
      field: :business_name_or_contact_name_or_contact_email_cont
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :vendor],
      :plus,
      "New Vendor"
    ]
  end

  def status_filter_data
    FilterComponent::Data.new(
      "Status",
      "status[]",
      [
        OpenStruct.new(id: "active", name: "Active"),
        OpenStruct.new(id: "inactive", name: "Inactive")
      ]
    )
  end

  def resource_facade_class
    Admin::Vendors::ResourceFacade
  end
end
