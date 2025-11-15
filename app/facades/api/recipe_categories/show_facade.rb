class Api::RecipeCategories::ShowFacade
  def initialize(user, params, request = nil)
    @user = user
    @params = params
    @request = request
  end

  def recipe_category
    @recipe_category ||= RecipeCategory.find(@params[:id])
  end

  def recipes
    puts "*" * 100
    puts @params
    puts "*" * 100
    @recipes ||= recipe_category.recipes.filtered_by_duration(@params.dig(:filter, :duration)).ransack(@params[:q]).result
  end
end
