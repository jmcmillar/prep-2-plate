require "test_helper"

class MealPlans::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = MealPlans::ShowFacade.new(@user, { id: @meal_plan.id })
  end

  def test_resource
    assert_equal @meal_plan, @facade.resource
  end

  def test_name
    assert_equal @meal_plan.name, @facade.name
  end

  def test_description
    assert_equal @meal_plan.description, @facade.description
  end

  def test_active_key
    assert_equal :meal_plans, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Meal Plans", trail.first.text
    assert_equal @meal_plan.name, trail.last.text
  end
end
