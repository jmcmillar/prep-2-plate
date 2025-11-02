class MyRecipesController < AuthenticatedController
  layout "application"
  def index
    @facade = MyRecipes::IndexFacade.new Current.user, params
  end
end
