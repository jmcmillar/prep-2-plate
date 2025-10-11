class Admin::MeasurementUnitAliases::DestroyFacade < Base::Admin::DestroyFacade
  def measurement_unit_alias
    @measurement_unit_alias ||= MeasurementUnitAlias.find(@params[:id])
  end
end
