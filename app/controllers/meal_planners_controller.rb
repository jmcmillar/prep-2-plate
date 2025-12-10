class MealPlannersController < AuthenticatedController
  layout "application"

  def show
    @facade = MealPlanners::ShowFacade.new(Current.user, params, session: session)
  end
end
