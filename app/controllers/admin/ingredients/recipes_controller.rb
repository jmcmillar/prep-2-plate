class Admin::Ingredients::RecipesController < AuthenticatedController
  def index
    @facade = Admin::Ingredients::Recipes::IndexFacade.new(Current.user, params)
  end
end
