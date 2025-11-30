class Admin::IngredientCategories::EditFacade < Base::Admin::EditFacade
  def ingredient_category
    @ingredient_category ||= IngredientCategory.find(@params[:id])
  end

  def active_key
    :admin_ingredient_categories
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredient Categories", [:admin, :ingredient_categories]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
