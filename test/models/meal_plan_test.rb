require "test_helper"

class MealPlanTest < ActiveSupport::TestCase
  def test_featured_scope
    featured_meal_plans = MealPlan.featured
    assert featured_meal_plans.all? { |mp| mp.featured }
  end

  def test_non_user_associated_scope
    non_user_associated_meal_plans = MealPlan.non_user_associated
    non_user_associated_meal_plans.each do |meal_plan|
      assert_equal 0, meal_plan.user_meal_plans.count
    end
  end
end
