class Admin::MealPlanIngredientsController < AuthenticatedController
  def index
    @facade = Admin::MealPlanIngredients::IndexFacade.new(Current.user, params)
  end
end
