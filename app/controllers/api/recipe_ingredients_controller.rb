class Api::RecipeIngredientsController < Api::BaseController
  def index
    @facade = Api::RecipeIngredients::IndexFacade.new(current_user, params)
  end
end
