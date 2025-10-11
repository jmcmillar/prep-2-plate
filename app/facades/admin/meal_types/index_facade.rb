class Admin::MealTypes::IndexFacade < Base::Admin::IndexFacade
  # def columns
  #   [[:name, "Name"], [:action, "", Table::ActionComponent]]
  # end

  # def collection
  #   MealType.order(:name)
  # end

  # def policy_class
  #   MealTypePolicy
  # end
  def active_key
    :admin_meal_types
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, MealType.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Types")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :meal_type],
      :plus, 
      "New Meal Type",
      target: "_top"
    ]
  end

  def resource_facade_class
    Admin::MealTypes::ResourceFacade
  end
end
