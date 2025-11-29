require "test_helper"

class Admin::MealPlanRecipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlanRecipes::NewFacade.new(@admin, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan_recipe
    recipe = @facade.meal_plan_recipe
    
    assert_kind_of MealPlanRecipe, recipe
    assert recipe.new_record?
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_form_url
    assert_equal [:admin, @meal_plan, :meal_plan_recipes], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @meal_plan, :meal_plan_recipes], @facade.cancel_path
  end
end
