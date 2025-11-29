require "test_helper"

class Admin::MealPlans::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @facade = Admin::MealPlans::NewFacade.new(@admin, {})
  end

  def test_meal_plan
    plan = @facade.meal_plan
    
    assert_kind_of MealPlan, plan
    assert plan.new_record?
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plans", trail[1].text
    assert_equal "New", trail[2].text
  end
end
