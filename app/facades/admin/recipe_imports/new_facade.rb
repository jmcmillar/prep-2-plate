class Admin::RecipeImports::NewFacade < Base::Admin::IndexFacade
  def import
    @import ||= RecipeImport.new
  end

  def active_key
    :admin_recipes
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("New Import")
    ]
  end

  def form_url
    [:admin, :recipe_imports]
  end
end
