class Api::MeasurementUnitsController < Api::BaseController
  def index
    @measurement_units = MeasurementUnit.all.order(:name)
  end
end
