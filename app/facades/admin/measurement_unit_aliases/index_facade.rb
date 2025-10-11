class Admin::MeasurementUnitAliases::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_measurement_units
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, measurement_unit.measurement_unit_aliases.order(:name)).resolve
  end

  def measurement_unit
    @measurement_unit ||= MeasurementUnit.find(@params[:measurement_unit_id])
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, measurement_unit, :measurement_unit_alias],
      :plus, 
      "New Measurement Unit Alias",
    ]
  end

  def resource_facade_class
    Admin::MeasurementUnitAliases::ResourceFacade
  end
end
