require "test_helper"

class MealPlans::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @meal_plan = meal_plans(:one)
    @facade = MealPlans::ResourceFacade.new(@meal_plan)
  end

  def test_resource_returns_meal_plan
    assert_equal @meal_plan, @facade.resource
  end

  def test_name_returns_meal_plan_name
    assert_equal @meal_plan.name, @facade.name
  end

  def test_description_returns_meal_plan_description
    assert_equal @meal_plan.description, @facade.description
  end

  def test_duration_returns_duration_string
    assert_equal "7 days", @facade.duration
  end
end
