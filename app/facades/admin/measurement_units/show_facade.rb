class Admin::MeasurementUnits::ShowFacade < Base::Admin::ShowFacade
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
      BreadcrumbComponent::Data.new(measurement_unit.name)
    ]
  end


  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, measurement_unit],
      :edit, 
      "Measurement Unit"
    ]
  end
end
