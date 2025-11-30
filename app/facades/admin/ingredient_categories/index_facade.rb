class Admin::IngredientCategories::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_ingredient_categories
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, IngredientCategory.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredient Categories")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :ingredient_category],
      :plus, 
      "New Ingredient Category",
    ]
  end

  def resource_facade_class
    Admin::IngredientCategories::ResourceFacade
  end
end
