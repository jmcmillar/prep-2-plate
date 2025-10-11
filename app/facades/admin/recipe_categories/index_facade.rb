class Admin::RecipeCategories::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_recipe_categories
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, RecipeCategory.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Categories")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :recipe_category],
      :plus, 
      "New Recipe Category",
    ]
  end

  def resource_facade_class
    Admin::RecipeCategories::ResourceFacade
  end
end
