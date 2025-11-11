class Api::Recipes::ShowFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def id
    recipe.id
  end

  def name
    recipe.name
  end

  def duration
    recipe.duration_minutes
  end

  def servings
    recipe.serving_size
  end

  def difficulty_level
    recipe.difficulty_level&.titleize || "Unknown"
  end

  def favorite?
    @user.recipes.include?(recipe)
  end

  def allow_favorite?
    !recipe.user_recipe
  end

  def recipe
    @recipe ||= Recipe.includes(recipe_ingredients: [:measurement_unit, :ingredient]).find_by(id: @params[:id])
  end

  def instructions
    recipe.recipe_instructions.order(:step_number)
  end

  def ingredients
    @decorated_ingredients ||= RecipeIngredient::FullNameDecorator.decorate_collection(recipe.recipe_ingredients)
  end
end
