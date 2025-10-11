class Admin::MealPlanRecipes::EditFacade < Base::Admin::EditFacade
  def meal_plan_recipe
    @meal_plan_recipe ||= MealPlanRecipe.find(@params[:id])
  end

  def active_key
    :admin_meal_plans
  end

  def breadcrumb_trail
    []
  end

  def meal_plan
    meal_plan_recipe.meal_plan
  end

  def form_url
    [:admin, meal_plan_recipe]
  end

  def cancel_path
    [:admin, meal_plan, :meal_plan_recipes]
  end
end
