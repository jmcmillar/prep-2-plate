require "test_helper"

class Admin::MealPlanRecipes::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @recipe = recipes(:one)
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.create!(
      recipe: @recipe,
      date: Date.today
    )
    @facade = Admin::MealPlanRecipes::DestroyFacade.new(@admin, { id: @meal_plan_recipe.id })
  end

  def test_meal_plan_recipe
    assert_equal @meal_plan_recipe, @facade.meal_plan_recipe
  end
end
