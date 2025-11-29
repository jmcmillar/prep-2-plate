require "test_helper"

class Admin::MealPlanIngredients::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @meal_plan = meal_plans(:one)
    @recipe = recipes(:one)
    @ingredient = ingredients(:one)
    @unit = measurement_units(:one)
    @recipe.recipe_ingredients.create!(
      ingredient: @ingredient,
      measurement_unit: @unit,
      numerator: 1,
      denominator: 1
    )
    @meal_plan.meal_plan_recipes.create!(recipe: @recipe)
    @facade = Admin::MealPlanIngredients::IndexFacade.new(@admin, { meal_plan_id: @meal_plan.id })
  end

  def test_meal_plan
    assert_equal @meal_plan, @facade.meal_plan
  end

  def test_base_collection
    collection = @facade.base_collection
    
    assert_kind_of ActiveRecord::Relation, collection
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Meal Plan Ingredients", trail[1].text
  end

  def test_resource_facade_class
    assert_equal Admin::MealPlanIngredients::ResourceFacade, @facade.resource_facade_class
  end
end
