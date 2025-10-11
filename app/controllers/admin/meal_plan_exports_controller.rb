class Admin::MealPlanExportsController < AuthenticatedController
  before_action { set_active_menu :admin_meal_plans }
  
  def index
    @facade = Admin::MealPlanExports::IndexFacade.new(Current.user, params)

    respond_to do |format|
      format.ics { send_data @facade.calendar_export.to_ical, **@facade.calendar_file_options }
    end
  end

  def new
    @facade = Admin::MealPlanExports::NewFacade.new(Current.user, params)
  end
end
