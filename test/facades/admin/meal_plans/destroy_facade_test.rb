require "test_helper"

class Admin::MealPlans::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlans::DestroyFacade.new(@admin, { id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end
end
