class Admin::UserMealPlanRecipesController < AuthenticatedController
  def index
    @facade = Admin::UserMealPlanRecipes::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::UserMealPlanRecipes::ShowFacade.new(Current.user, params)
  end

  def destroy
    @facade = Admin::UserMealPlanRecipes::DestroyFacade.new(Current.user, params)
    @facade.meal_plan_recipe.destroy
    set_destroy_flash_for(@facade.meal_plan_recipe)
  end
end
