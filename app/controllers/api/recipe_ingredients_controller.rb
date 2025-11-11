class Api::RecipeIngredientsController < Api::BaseController
  def index
    @facade = Api::RecipeIngredients::IndexFacade.new(Current.user, params)
  end
end
