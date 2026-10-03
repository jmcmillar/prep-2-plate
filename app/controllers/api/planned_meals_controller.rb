class Api::PlannedMealsController < Api::BaseController
  rescue_from Date::Error, with: :invalid_dates

  def index
    @planned_meals = Current.user.planned_meals
      .where(date: date_range)
      .includes(recipe: { image_attachment: :blob })
      .ordered
  end

  def replace
    result = PlannedMeals::ReplaceRange.call(
      user: Current.user,
      dates: date_range,
      entries: params.fetch(:planned_meals, []).map { |entry| entry.permit(:date, :kind, :recipe_id) }
    )

    if result.success?
      @planned_meals = result.planned_meals
      render :index
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def date_range
    first = Date.iso8601(params.require(:start))
    last = Date.iso8601(params.require(:end))
    raise Date::Error, "end is before start" if last < first

    first..last
  end

  def invalid_dates
    render json: { status: 400, message: "start and end must be ISO 8601 dates" }, status: :bad_request
  end
end
