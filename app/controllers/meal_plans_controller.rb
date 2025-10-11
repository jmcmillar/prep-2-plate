class MealPlansController < ApplicationController
  def index
    @facade = MealPlans::IndexFacade.new Current.user, params
  end

  def show
    @facade = MealPlans::ShowFacade.new Current.user, params
  end
end
