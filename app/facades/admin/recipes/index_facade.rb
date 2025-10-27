class Admin::Recipes::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_recipes
  end
  
  def base_collection
    Base::AdminPolicy::Scope.new(@user, Recipe.order(:name).where.missing(:user_recipe)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :recipes],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :name_cont
    ]
  end

  def header_actions
    [import_action_data, new_action_data]
  end

  def import_action_data
    IconLinkComponent::Data[
      [:new, :admin, :recipe_import],
      :file_import, 
      "Import New Recipe",
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :recipe],
      :plus, 
      "New Recipe",
    ]
  end

  def resource_facade_class
    Admin::Recipes::ResourceFacade
  end
end
