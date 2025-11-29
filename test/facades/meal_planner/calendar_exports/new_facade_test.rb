require "test_helper"

class MealPlanner::CalendarExports::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @session = {
      meal_plan: {
        "2025-11-25" => {
          "recipes" => [{ "id" => @recipe.id, "name" => @recipe.name }],
          "notes" => ""
        }
      }
    }
    @facade = MealPlanner::CalendarExports::NewFacade.new(@user, {}, session: @session)
  end

  def test_meal_plan
    assert_equal @session[:meal_plan], @facade.meal_plan
  end

  def test_calendar_file_options
    options = @facade.calendar_file_options
    
    assert_equal 'text/calendar', options[:type]
    assert_match(/\.ics$/, options[:filename])
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of Array, recipes
    assert recipes.any? { |r| r.is_a?(MealPlanner::CalendarExports::NewFacade::RecipeCalendarData) }
  end
end
