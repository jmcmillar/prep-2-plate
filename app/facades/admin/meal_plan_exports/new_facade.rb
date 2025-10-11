class Admin::MealPlanExports::NewFacade < Base::Admin::IndexFacade
  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:meal_plan_id])
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans", [:admin, :meal_plans]),
      BreadcrumbComponent::Data.new(meal_plan.name, [:admin, meal_plan]),
      BreadcrumbComponent::Data.new("Export Meal Plan")
    ]
  end

  def form_url
    [:admin, meal_plan, :meal_plan_exports]
  end

  private

  def meal_plan_name
    meal_plan.name
  end
end
