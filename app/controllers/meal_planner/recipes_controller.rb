class MealPlanner::RecipesController < AuthenticatedController
  def index
    @facade = MealPlanner::Recipes::IndexFacade.new(Current.user, params, session: session)
  end

  def create
    @facade = MealPlanner::Recipes::NewFacade.new(Current.user, params, session: session)
    @facade.append_to_meal_plan
    @facade.append_to_selected_recipes
  end

  def destroy
    @facade = MealPlanner::Recipes::DestroyFacade.new(Current.user, params, session: session)
    @facade.remove_from_meal_plan
    @facade.remove_from_selected_recipes
  end
end
