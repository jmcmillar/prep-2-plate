class Admin::Ingredients::ShowFacade < Base::Admin::ShowFacade
  def ingredient
    @ingredient ||= Ingredient.find(@params[:id])
  end

  def active_key
    :admin_ingredients
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredients", [:admin, :ingredients]),
      BreadcrumbComponent::Data.new(ingredient.name)
    ]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, ingredient],
      :edit,
      "Ingredient"
    ]
  end

  def recipes
    @recipes ||= Recipe.joins(:recipe_ingredients)
                       .where(recipe_ingredients: { ingredient_id: ingredient.id })
                       .distinct
                       .order(:name)
  end

  def recipes_count
    recipes.count
  end
end
