class Admin::MeasurementUnits::NewFacade < Base::Admin::NewFacade
  def measurement_unit
    @measurement_unit ||= MeasurementUnit.new
  end

  def active_key
    :admin_measurement_units
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Measurement Units", [:admin, :measurement_units]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
