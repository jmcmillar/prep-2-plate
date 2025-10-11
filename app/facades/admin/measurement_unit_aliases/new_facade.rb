class Admin::MeasurementUnitAliases::NewFacade < Base::Admin::NewFacade
  def measurement_unit_alias
    @measurement_unit_alias ||= measurement_unit.measurement_unit_aliases.new
  end

  def active_key
    :admin_measurement_units
  end

  def measurement_unit
    @measurement_unit ||= MeasurementUnit.find(params[:measurement_unit_id])
  end

  def form_url
    [:admin, measurement_unit, :measurement_unit_aliases]
  end

  def cancel_path
    [:admin, measurement_unit, :measurement_unit_aliases]
  end
end
