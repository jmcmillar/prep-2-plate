class MealPlanner::CalendarExportsController < AuthenticatedController

  def new
    @facade = MealPlanner::CalendarExports::NewFacade.new(Current.user, params, session: session)
  end

  def create
    @facade = MealPlanner::CalendarExports::NewFacade.new(Current.user, params, session: session)
    respond_to do |format|
      format.ics { send_data @facade.calendar_export.to_ical, **@facade.calendar_file_options }
    end
  end
end
