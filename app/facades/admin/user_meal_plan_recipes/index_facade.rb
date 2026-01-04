class Admin::UserMealPlanRecipes::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_user_meal_plans
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    user_meal_plan.user
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, user_meal_plan.meal_plan.meal_plan_recipes.includes(:recipe)).resolve
  end

  def calendar_events
    base_collection.map do |meal_plan_recipe|
      {
        id: meal_plan_recipe.id,
        title: meal_plan_recipe.recipe.name,
        start: meal_plan_recipe.date,
      } if meal_plan_recipe.date
    end.compact
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("User Meal Plans", [:admin, :user_meal_plans]),
      BreadcrumbComponent::Data.new(user_meal_plan.meal_plan.name, [:admin, user_meal_plan]),
      BreadcrumbComponent::Data.new("Recipes")
    ]
  end

  def user_meal_plan
    @user_meal_plan ||= UserMealPlan.includes(meal_plan: :meal_plan_recipes).find(@params[:user_meal_plan_id])
  end

  def resource_facade_class
    Admin::UserMealPlanRecipes::ResourceFacade
  end
end
