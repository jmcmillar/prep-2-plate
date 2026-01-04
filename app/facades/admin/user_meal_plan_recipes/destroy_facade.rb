class Admin::UserMealPlanRecipes::DestroyFacade < Base::Admin::DestroyFacade
  def meal_plan_recipe
    @meal_plan_recipe ||= MealPlanRecipe.find(@params[:id])
  end
end
