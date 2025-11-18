class Api::RecipeCategories::ShowFacade
  def initialize(user, params, request = nil)
    @user = user
    @params = params
    @request = request
  end

  def recipe_category
    @recipe_category ||= RecipeCategory.find_by(id: @params[:id])
  end

  def recipes
    @recipes ||= base_recipes.filtered_by_duration(@params.dig(:filter, :duration)).ransack(@params[:q]).result
  end

  def base_recipes
    return Recipe.includes(:user_recipe).where(user_recipe: { user_id: @user.id }) unless recipe_category

    recipe_category.recipes
  end
end
