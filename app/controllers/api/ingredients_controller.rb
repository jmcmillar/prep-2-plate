class Api::IngredientsController < Api::BaseController
  def suggest
    @facade = Api::Ingredients::SuggestFacade.new(params)
  end
end
