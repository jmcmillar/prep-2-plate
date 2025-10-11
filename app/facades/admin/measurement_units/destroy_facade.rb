class Admin::MeasurementUnits::DestroyFacade < Base::Admin::DestroyFacade
  def measurement_unit
    @measurement_unit ||= MeasurementUnit.find(@params[:id])
  end
end
