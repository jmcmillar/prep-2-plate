class Admin::UserMealPlanRecipes::ShowFacade < Base::Admin::ShowFacade
  def meal_plan_recipe
    @meal_plan_recipe ||= MealPlanRecipe.includes(:recipe, meal_plan: { user_meal_plans: :user }).find(@params[:id])
  end

  def user_meal_plan
    @user_meal_plan ||= meal_plan_recipe.meal_plan.user_meal_plans.first
  end

  def menu
    :admin_user_menu
  end

  def active_key
    :admin_user_meal_plans
  end

  def nav_resource
    user_meal_plan&.user
  end

  def header_actions
    []
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("User Meal Plans", [:admin, :user_meal_plans]),
      BreadcrumbComponent::Data.new(meal_plan_recipe.meal_plan.name, [:admin, user_meal_plan]),
      BreadcrumbComponent::Data.new(meal_plan_recipe.recipe.name)
    ]
  end
end
