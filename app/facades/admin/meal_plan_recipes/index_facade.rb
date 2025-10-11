class Admin::MealPlanRecipes::IndexFacade < Base::Admin::IndexFacade
  def base_collection
    Base::AdminPolicy::Scope.new(@user, meal_plan.meal_plan_recipes.includes(:recipe)).resolve
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
      BreadcrumbComponent::Data.new("Meal Plan Recipes")
    ]
  end

  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:meal_plan_id])
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, meal_plan, :meal_plan_recipe],
      :plus, 
      "New Recipe Ingredient",
    ]
  end

  def resource_facade_class
    Admin::MealPlanRecipes::ResourceFacade
  end
end
