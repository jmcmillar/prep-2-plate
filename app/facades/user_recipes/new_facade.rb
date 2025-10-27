class UserRecipes::NewFacade < BaseFacade
  DifficultyLevel = Struct.new(:name, :value)
  def user_recipe
    @user_recipe ||= @user.user_recipes.new.tap do |ur|
      ur.build_recipe.tap do |recipe|
        # Build initial empty fields
        # recipe.recipe_ingredients.build
        # recipe.recipe_instructions.build
      end
    end
  end

  def form_url
    [user_recipe]
  end

  def difficulty_levels
    Recipe.difficulty_levels.map do |level|
      DifficultyLevel[*level]
    end
  end

  def categories
    @categories ||= RecipeCategory.all.order(:name)
  end

  def meal_types
    @meal_types ||= MealType.all.order(:name)
  end

  def ingredients
    @ingredients ||= Ingredient.all.order(:name)
  end

  def measurement_units
    @measurement_units ||= MeasurementUnit.all.order(:name)
  end

  def new_user_recipe_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "New Recipe",
      [:new, :user_recipe],
      :plus,
      :primary,
    ]
  end
end
