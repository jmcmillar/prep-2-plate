class Admin::Ingredients::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_ingredients
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, Ingredient.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredients")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :ingredients],
      query: collection.search_collection,
      label: "Search Name",
      field: :name_cont
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :ingredient],
      :plus, 
      "New Ingredient",
      target: "_top"
    ]
  end

  def resource_facade_class
    Admin::Ingredients::ResourceFacade
  end
end
