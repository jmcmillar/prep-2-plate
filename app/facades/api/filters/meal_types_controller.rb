class Api::Filters::MealTypesController < Api::BaseController
  def index
    @meal_types = MealType.all
  end
end
