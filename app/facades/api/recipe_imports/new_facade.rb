class Api::RecipeImports::NewFacade
  NOT_FOUND_ERROR = "Could not find a recipe with a name and ingredients at this URL.".freeze

  def initialize(user, params)
    @user = user
    @params = params
  end

  def recipe
    @recipe ||= RecipeImports::BuildRecipe.call(parsed_recipe, recipe_import: recipe_import).tap do |recipe|
      recipe.build_user_recipe(user: @user)
      recipe.recipe_categories = RecipeCategory.where(id: Array(@params[:recipe_category_ids]).compact_blank)
    end
  end

  # Saves the recipe, its import record and the user's ownership in one
  # transaction, then queues categorization for any new ingredients.
  def save
    return false unless recipe_found? && recipe.save

    RecipeImports::ScheduleIngredientCategorization.call
    true
  end

  def errors
    return [ NOT_FOUND_ERROR ] unless recipe_found?

    recipe.errors.full_messages
  end

  private

  def recipe_found?
    parsed_recipe[:name].present? && parsed_recipe[:ingredients].present?
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(@params[:url]).to_h
  end

  def recipe_import
    @recipe_import ||= RecipeImport.find_or_initialize_by(url: @params[:url])
  end
end
