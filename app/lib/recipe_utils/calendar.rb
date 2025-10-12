class RecipeUtils::Calendar
  def initialize(recipes)
    @recipes = recipes
    @calendar = Icalendar::Calendar.new
  end

  def build
    add_recipes_to_calendar
    @calendar
  end

  private

  def add_recipes_to_calendar
    @recipes.each_with_index { |r, index| 
      event = RecipeUtils::CalendarEvent.new(r, r.date).create
      @calendar.add_event(event)
    }
  end
end
