class Admin::MeasurementUnitsController < AuthenticatedController
  def index
    @facade = Admin::MeasurementUnits::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::MeasurementUnits::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::MeasurementUnits::EditFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::MeasurementUnits::ShowFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::MeasurementUnits::NewFacade.new(Current.user, params)
    @facade.measurement_unit.assign_attributes(measurement_unit_params)
    if @facade.measurement_unit.save
      redirect_to admin_measurement_units_url, notice: "Measurement unit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::MeasurementUnits::EditFacade.new(Current.user, params)
    @facade.measurement_unit.assign_attributes(measurement_unit_params)
    if @facade.measurement_unit.update!(measurement_unit_params)
      redirect_to admin_measurement_units_url, notice: "Measurement unit was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::MeasurementUnits::DestroyFacade.new(Current.user, params)
    @facade.measurement_unit.destroy
    set_destroy_flash_for(@facade.measurement_unit)
  end

  private

  def measurement_unit_params
    params.require(:measurement_unit).permit(:name)
  end
end
