require "test_helper"

class Admin::MealPlans::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlans::EditFacade.new(@admin, { id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plans", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
