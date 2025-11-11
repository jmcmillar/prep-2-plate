class Api::RecipeCategoriesController < Api::BaseController
  def index
    @facade = Api::RecipeCategories::IndexFacade.new(
      Current.user,
      params,
      request
    )
  end

  def show
    @facade = Api::RecipeCategories::ShowFacade.new(
      Current.user,
      params,
      request
    )
  end
end
