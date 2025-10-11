class Admin::MealPlans::EditFacade < Base::Admin::EditFacade
  def meal_plan
    @meal_plan ||= MealPlan.find(params[:id])
  end

  def active_key
    :admin_meal_plans
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans", [:admin, :meal_plans]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
