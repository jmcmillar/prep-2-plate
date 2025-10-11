class Admin::MealPlans::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_meal_plans
  end
  
  def base_collection
    Base::AdminPolicy::Scope.new(@user, MealPlan.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans")
    ]
  end


  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :meal_plan],
      :plus, 
      "New Meal Plan",
      target: "_top"
    ]
  end

  def resource_facade_class
    Admin::MealPlans::ResourceFacade
  end
end
