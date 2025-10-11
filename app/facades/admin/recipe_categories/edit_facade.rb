class Admin::RecipeCategories::EditFacade < Base::Admin::EditFacade
  def recipe_category
    @recipe_category ||= RecipeCategory.find(@params[:id])
  end

  def active_key
    :admin_recipe_categories
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Categories", [:admin, :recipe_categories]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
