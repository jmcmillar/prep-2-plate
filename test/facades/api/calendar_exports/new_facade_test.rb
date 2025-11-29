require "test_helper"

class Api::CalendarExports::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @params = {
      "2025-11-29" => {
        "recipeIds" => [@recipe.id]
      }
    }
    @facade = Api::CalendarExports::NewFacade.new(@user, @params)
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of Array, recipes
    assert recipes.length > 0
    assert_equal @recipe.id, recipes.first.id
    assert_equal @recipe.name, recipes.first.recipe_name
  end

  def test_calendar_export
    calendar = @facade.calendar_export
    
    assert_kind_of Icalendar::Calendar, calendar
    assert calendar.events.length > 0
  end

  def test_calendar_file_options
    options = @facade.calendar_file_options
    
    assert_equal 'text/calendar', options[:type]
    assert_includes options[:filename], ".ics"
  end
end
