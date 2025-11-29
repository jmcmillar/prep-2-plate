require "test_helper"

class MealPlanner::ExportToShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @recipe = recipes(:one)
    @session = { selected_recipe_ids: [@recipe.id] }
    @facade = MealPlanner::ExportToShoppingLists::NewFacade.new(@user, {}, session: @session)
  end

  def test_shopping_lists
    assert_includes @facade.shopping_lists, @shopping_list
  end

  def test_recipes
    assert_includes @facade.recipes, @recipe
  end

  def test_ingredients
    recipe_ingredient = @recipe.recipe_ingredients.create!(
      ingredient: ingredients(:one),
      measurement_unit: measurement_units(:one)
    )
    
    assert_includes @facade.ingredients, recipe_ingredient
  end

  def test_active_key
    assert_equal :meal_plans, @facade.active_key
  end
end
