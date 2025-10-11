class Admin::Recipes::ShowFacade < Base::Admin::ShowFacade
  def recipe
    @recipe ||= Recipe.find(@params[:id])
  end
  
  def recipe_ingredients
    RecipeIngredient::FullNameDecorator.decorate_collection(recipe.recipe_ingredients)
  end

  def active_key
    :admin_recipes
  end

  def meal_types
    recipe.meal_types.order(:name).pluck(:name).join(", ")
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, :recipes]),
      BreadcrumbComponent::Data.new(recipe.name)
    ]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, recipe],
      :edit, 
      "Recipe",
    ]
  end
end
