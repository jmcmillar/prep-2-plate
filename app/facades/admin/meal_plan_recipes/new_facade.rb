class Admin::MealPlanRecipes::NewFacade < Base::Admin::NewFacade
  def meal_plan_recipe
    @meal_plan_recipe ||= meal_plan.meal_plan_recipes.new
  end

  def meal_plan
    @meal_plan ||= MealPlan.find(params[:meal_plan_id])
  end

  def active_key
    :admin_meal_plans
  end

  def form_url
    [:admin, meal_plan, :meal_plan_recipes]
  end

  def cancel_path
    [:admin, meal_plan, :meal_plan_recipes]
  end
end
