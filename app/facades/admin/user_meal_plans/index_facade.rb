class Admin::UserMealPlans::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_user_meal_plans
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    meal_plan_user
  end

  def header_actions
    []
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, meal_plan_user.user_meal_plans.includes(:meal_plan).order("meal_plans.name")).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("User Meal Plans")
    ]
  end

  def meal_plan_user
    @meal_plan_user ||= User.find(@params[:user_id])
  end

  def resource_facade_class
    Admin::UserMealPlans::ResourceFacade
  end
end
