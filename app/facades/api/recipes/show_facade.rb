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
    @favorite ||= RecipeFavorite.exists?(user: @user, recipe: recipe)
  end

  def allow_favorite?
    !recipe.user_recipe
  end

  def allow_edit?
    return false unless recipe.user_recipe
    recipe.user_recipe.user_id == @user.id
  end

  def recipe
    @recipe ||= Recipe.includes(
      :recipe_instructions,
      recipe_ingredients: [:measurement_unit, { ingredient: :ingredient_category }]
    ).find_by(id: @params[:id])
  end

  def instructions
    recipe.recipe_instructions.order(:step_number)
  end

  def ingredients
    @decorated_ingredients ||= RecipeIngredient::FullNameDecorator.decorate_collection(recipe.recipe_ingredients)
  end

  def grouped_ingredients
    @grouped_ingredients ||= ingredients.group_by do |recipe_ingredient|
      recipe_ingredient.ingredient.ingredient_category || uncategorized_category
    end.sort_by { |category, _| category.name }
  end

  private

  def uncategorized_category
    @uncategorized_category ||= IngredientCategory.new(id: nil, name: "Uncategorized")
  end
end
