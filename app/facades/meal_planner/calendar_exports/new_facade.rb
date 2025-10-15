class MealPlanner::CalendarExports::NewFacade < BaseFacade
  RecipeCalendarData = Struct.new(:id, :recipe_name, :date)
  def meal_plan
    @meal_plan ||= @session[:meal_plan]
  end

  def calendar_export
    @calendar_export =  RecipeUtils::Calendar.new(recipes).build
  end

  def calendar_file_options
    {
      filename: "#{Date.current}_meal_plan.ics",
      type: 'text/calendar'
    }
  end

  def recipes
    meal_plan.each.map do |(recipe_date, day_data)|
      day_data["recipes"].map do |recipe|
        RecipeCalendarData.new(recipe["id"], recipe["name"], recipe_date.to_date)
      end.flatten
    end.flatten
  end

  def start_date
    Date.current
  end
end
