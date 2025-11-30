class Admin::IngredientCategories::NewFacade < Base::Admin::NewFacade
  def ingredient_category
    @ingredient_category ||= IngredientCategory.new
  end

  def active_key
    :admin_ingredient_categories
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredient Categories", [:admin, :ingredient_categories]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
