class Admin::MeasurementUnits::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_measurement_units
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, MeasurementUnit.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :measurement_unit],
      :plus, 
      "New Measurement Unit",
    ]
  end

  def resource_facade_class
    Admin::MeasurementUnits::ResourceFacade
  end
end
