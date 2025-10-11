class Admin::MealPlanIngredients::IndexFacade < Base::Admin::IndexFacade
  def base_collection
    @collection ||= Base::AdminPolicy::Scope.new(@user, MealPlanIngredient.where(meal_plan_id: meal_plan.id)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plan Ingredients")
    ]
  end

  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:meal_plan_id])
  end

  def resource_facade_class
    Admin::MealPlanIngredients::ResourceFacade
  end
end
