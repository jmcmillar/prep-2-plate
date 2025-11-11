class Api::CalendarExports::NewFacade
  RecipeCalendarData = Struct.new(:id, :recipe_name, :date)
  def initialize(user, params)
    @user = user
    @params = params
  end

  def calendar_export
    @calendar_export = Recipe::Calendar.new(recipes).build
  end

  def calendar_file_options
    {
      filename: "#{Date.current}_meal_plan.ics",
      type: 'text/calendar'
    }
  end
  
  def recipes
    @params.each.map do |(recipe_date, day_data)|
      day_data.map do |recipe|
        RecipeCalendarData.new(recipe["id"], recipe["name"], recipe_date.to_date)
      end.flatten
    end.flatten
  end
end
