require "test_helper"

class Admin::MealPlanRecipes::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @recipe = recipes(:one)
    @meal_plan_recipe = @meal_plan.meal_plan_recipes.create!(
      recipe: @recipe,
      date: Date.today
    )
    @facade = Admin::MealPlanRecipes::EditFacade.new(@admin, { id: @meal_plan_recipe.id })
  end

  def test_meal_plan_recipe
    assert_equal @meal_plan_recipe, @facade.meal_plan_recipe
  end

  def test_active_key
    assert_equal :admin_meal_plans, @facade.active_key
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 0, trail.length
  end

  def test_form_url
    assert_equal [:admin, @meal_plan_recipe], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @meal_plan, :meal_plan_recipes], @facade.cancel_path
  end
end
