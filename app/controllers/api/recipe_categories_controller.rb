class Api::RecipeCategoriesController < Api::BaseController
  def index
    @facade = Api::RecipeCategories::IndexFacade.new(
      current_user,
      params,
      request
    )
  end

  def show
    @facade = Api::RecipeCategories::ShowFacade.new(
      current_user,
      params,
      request
    )
  end
end
