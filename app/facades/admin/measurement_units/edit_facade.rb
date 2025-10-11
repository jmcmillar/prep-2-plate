class Admin::MeasurementUnits::EditFacade < Base::Admin::EditFacade
  def measurement_unit
    @measurement_unit ||= MeasurementUnit.find(@params[:id])
  end

  def active_key
    :admin_measurement_units
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Measurement Units", [:admin, :measurement_units]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
