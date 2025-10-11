class Admin::Resources::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_resources
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, Resource.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Resources")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :resources],
      query: collection.search_collection,
      label: "Search Name",
      field: :name_cont
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :resource],
      :plus, 
      "New Resource"
    ]
  end

  def resource_facade_class
    Admin::Resources::ResourceFacade
  end
end
