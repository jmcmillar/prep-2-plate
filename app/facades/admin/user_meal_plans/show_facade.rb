class Admin::UserMealPlans::ShowFacade < Base::Admin::ShowFacade
  def user_meal_plan
    @user_meal_plan ||= UserMealPlan.includes(:meal_plan).find(@params[:id])
  end

  def menu
    :admin_user_menu
  end

  def active_key
    :admin_user_meal_plans
  end

  def header_actions
    []
  end

  def nav_resource
    user_meal_plan.user
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("User Meal Plans", [:admin, user_meal_plan.user, :user_meal_plans]),
      BreadcrumbComponent::Data.new(user_meal_plan.meal_plan.name)
    ]
  end
end
