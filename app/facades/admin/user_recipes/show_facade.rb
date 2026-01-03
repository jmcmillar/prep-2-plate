class Admin::UserRecipes::ShowFacade < Base::Admin::ShowFacade
  def user_recipe
    @recipe ||= UserRecipe.find(@params[:id])
  end

  def parent_resource
    user_recipe.user
  end
  
  def recipe_ingredients
    IngredientFullNameDecorator.decorate_collection(user_recipe.recipe_ingredients)
  end

  def active_key
    :admin_recipes
  end

  def meal_types
    user_recipe.meal_types.order(:name).pluck(:name).join(", ")
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new(parent_resource.email, [:admin, parent_resource]),
      BreadcrumbComponent::Data.new("Recipes", [:admin, parent_resource,:user_recipes]),
      BreadcrumbComponent::Data.new(user_recipe.name)
    ]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, user_recipe],
      :edit,
      "Recipe",
    ]
  end

  def user_recipe_image
    safe_attachment(user_recipe.image, 'no-recipe-image.png').url
  end
end
