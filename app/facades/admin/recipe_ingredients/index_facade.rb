class Admin::RecipeIngredients::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_recipes
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, recipe.recipe_ingredients.includes([:measurement_unit, :ingredient])).resolve
  end

  def recipe
    recipe ||= Recipe.find(@params[:recipe_id])
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Ingredients")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, recipe, :recipe_ingredient],
      :plus, 
      "New Recipe Ingredient",
    ]
  end

  def resource_facade_class
    Admin::RecipeIngredients::ResourceFacade
  end
end
