class UserRecipes::EditFacade < BaseFacade
  DifficultyLevel = Struct.new(:name, :value)
  def user_recipe
    @user_recipe ||= UserRecipe.find_by(id: @params[:id], user: @user)
  end

  def recipe
    user_recipe.recipe
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
end
