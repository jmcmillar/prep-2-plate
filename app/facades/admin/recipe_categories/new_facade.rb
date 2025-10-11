class Admin::RecipeCategories::NewFacade < Base::Admin::NewFacade
  def recipe_category
    @recipe_category ||= RecipeCategory.new
  end

  def active_key
    :admin_recipe_categories
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Categories", [:admin, :recipe_categories]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
