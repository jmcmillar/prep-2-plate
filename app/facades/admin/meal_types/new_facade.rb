class Admin::MealTypes::NewFacade < Base::Admin::NewFacade
  def meal_type
    @meal_type ||= MealType.new
  end

  def active_key
    :admin_meal_types
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Types", [:admin, :meal_types]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
