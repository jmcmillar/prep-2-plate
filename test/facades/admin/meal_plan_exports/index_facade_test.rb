require "test_helper"

class Admin::MealPlanExports::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @recipe = recipes(:one)
    @meal_plan.meal_plan_recipes.create!(recipe: @recipe, date: Date.today)
    @facade = Admin::MealPlanExports::IndexFacade.new(@admin, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_recipes
    recipes = @facade.recipes
    
    assert_kind_of ActiveRecord::Relation, recipes
  end

  def test_calendar_export
    calendar = @facade.calendar_export
    
    assert_kind_of Icalendar::Calendar, calendar
  end

  def test_calendar_file_options
    options = @facade.calendar_file_options
    
    assert_equal 'text/calendar', options[:type]
    assert_includes options[:filename], ".ics"
  end
end
