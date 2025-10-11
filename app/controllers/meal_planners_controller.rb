class MealPlannersController < AuthenticatedController
  layout "application"
  def show
    @facade = MealPlanners::ShowFacade.new(Current.user, params, session: session)
  end

  def update_note
    day_index = params[:day].to_i
    note = params[:note]

    session[:meal_plan] ||= {}
    day_name = Date::DAYNAMES[day_index]

    session[:meal_plan][day_name] ||= {}
    session[:meal_plan][day_name]["notes"] = note

    head :ok
  end
end
