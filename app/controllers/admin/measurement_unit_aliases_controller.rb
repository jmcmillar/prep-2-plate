class Admin::MeasurementUnitAliasesController < AuthenticatedController
  def index
    @facade = Admin::MeasurementUnitAliases::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::MeasurementUnitAliases::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::MeasurementUnitAliases::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::MeasurementUnitAliases::NewFacade.new(Current.user, params)
    @facade.measurement_unit_alias.assign_attributes(measurement_unit_alias_params)
    if @facade.measurement_unit_alias.save
      redirect_to admin_measurement_unit_measurement_unit_aliases_url(@facade.measurement_unit), notice: "Measurement unit alias was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::MeasurementUnitAliases::EditFacade.new(Current.user, params)
    @facade.measurement_unit_alias.assign_attributes(measurement_unit_alias_params)
    if @facade.measurement_unit_alias.update!(measurement_unit_alias_params)
      redirect_to admin_measurement_unit_measurement_unit_aliases_url(@facade.measurement_unit), notice: "Measurement unit alias was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::MeasurementUnitAliases::DestroyFacade.new(Current.user, params)
    @facade.measurement_unit_alias.destroy
    set_destroy_flash_for(@facade.measurement_unit_alias)
  end

  private

  def measurement_unit_alias_params
    params.require(:measurement_unit_alias).permit(:name)
  end
end
