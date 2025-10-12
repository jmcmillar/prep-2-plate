class Admin::MealPlanExports::IndexFacade < Base::Admin::IndexFacade
  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:meal_plan_id])
  end

  def recipes
    @recipes ||= meal_plan.meal_plan_recipes.includes(:recipe).order(:date)
  end

  # def start_at
  #   return DateTime.now unless @params[:start_on].present?

  #   DateTime.parse(@params[:start_on])
  # end

  def calendar_file_options
    {
      filename: "#{meal_plan_name}.ics",
      type: 'text/calendar'
    }
  end

  def calendar_export
    @calendar_export ||= Recipes::Calendar.new(recipes).build
  end

  private

  def meal_plan_name
    meal_plan.name
  end
end
