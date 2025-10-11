class Admin::MeasurementUnitAliases::EditFacade < Base::Admin::EditFacade
  def measurement_unit_alias
    @measurement_unit_alias ||= MeasurementUnitAlias.find(@params[:id])
  end

  def active_key
    :admin_measurement_units
  end

  def form_url
    [:admin, measurement_unit_alias]
  end

  def cancel_path
    [:admin, measurement_unit, :measurement_unit_aliases]
  end

  def measurement_unit
    @measurement_unit ||= measurement_unit_alias.measurement_unit
  end
end
