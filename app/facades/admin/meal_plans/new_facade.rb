class Admin::MealPlans::NewFacade < Base::Admin::NewFacade
  def meal_plan
    @meal_plan ||= MealPlan.new
  end

  def active_key
    :admin_meal_plans
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans", [:admin, :meal_plans]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
