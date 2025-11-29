require "test_helper"

class Admin::MealPlanExports::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlanExports::NewFacade.new(@admin, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 4, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plans", trail[1].text
    assert_equal "Export Meal Plan", trail[3].text
  end

  def test_form_url
    assert_equal [:admin, @meal_plan, :meal_plan_exports], @facade.form_url
  end
end
