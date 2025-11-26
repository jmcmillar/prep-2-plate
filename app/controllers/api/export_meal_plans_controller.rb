class Api::ExportMealPlansController < Api::BaseController
  def create
    @facade = Api::CalendarExports::NewFacade.new(Current.user, calendar_export_params)
    send_data @facade.calendar_export.to_ical, **@facade.calendar_file_options
  end

  def calendar_export_params
    params.require(:export_meal_plan)
  end
end
