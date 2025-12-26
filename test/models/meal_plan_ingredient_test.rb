require "test_helper"

class MealPlanIngredientTest < ActiveSupport::TestCase
  def test_includes_ingredient_id
    meal_plan = meal_plans(:one)
    # Add some recipes to the meal plan
    recipe = recipes(:one)
    meal_plan.meal_plan_recipes.create!(recipe: recipe)

    ingredients = MealPlanIngredient.where(meal_plan_id: meal_plan.id)
    assert ingredients.any?, "Should have some ingredients"

    ingredient = ingredients.first
    assert_not_nil ingredient.ingredient_id, "Should have ingredient_id"
  end

  def test_includes_packaging_form
    meal_plan = meal_plans(:one)
    recipe = recipes(:one)
    meal_plan.meal_plan_recipes.create!(recipe: recipe)

    ingredient = MealPlanIngredient.where(meal_plan_id: meal_plan.id).first
    # May be nil, but attribute should exist
    assert_respond_to ingredient, :packaging_form
  end

  def test_includes_preparation_style
    meal_plan = meal_plans(:one)
    recipe = recipes(:one)
    meal_plan.meal_plan_recipes.create!(recipe: recipe)

    ingredient = MealPlanIngredient.where(meal_plan_id: meal_plan.id).first
    # May be nil, but attribute should exist
    assert_respond_to ingredient, :preparation_style
  end

  def test_aggregates_separately_by_packaging
    meal_plan = meal_plans(:one)

    # Create two recipes with same ingredient but different packaging
    canned_tomatoes = Ingredient.find_or_create_by!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    fresh_tomatoes = Ingredient.find_or_create_by!(
      name: "tomatoes",
      packaging_form: "fresh",
      preparation_style: "diced"
    )

    unit = measurement_units(:two)  # cup

    recipe1 = Recipe.create!(
      name: "Recipe with canned tomatoes",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe1.recipe_ingredients.create!(
      ingredient: canned_tomatoes,
      numerator: 2,
      denominator: 1,
      measurement_unit: unit
    )

    recipe2 = Recipe.create!(
      name: "Recipe with fresh tomatoes",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe2.recipe_ingredients.create!(
      ingredient: fresh_tomatoes,
      numerator: 1,
      denominator: 1,
      measurement_unit: unit
    )

    meal_plan.meal_plan_recipes.create!(recipe: recipe1)
    meal_plan.meal_plan_recipes.create!(recipe: recipe2)

    tomato_ingredients = MealPlanIngredient.where(
      meal_plan_id: meal_plan.id,
      name: "tomatoes"
    )

    assert_equal 2, tomato_ingredients.count, "Should have 2 separate rows for different packaging"

    canned = tomato_ingredients.find { |i| i.packaging_form == "canned" }
    fresh = tomato_ingredients.find { |i| i.packaging_form == "fresh" }

    assert_not_nil canned, "Should have canned tomatoes"
    assert_not_nil fresh, "Should have fresh tomatoes"
  end

  def test_aggregates_separately_by_preparation
    meal_plan = meal_plans(:one)

    # Create two recipes with same ingredient but different preparation
    diced_tomatoes = Ingredient.find_or_create_by!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    whole_tomatoes = Ingredient.find_or_create_by!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "whole"
    )

    unit = measurement_units(:two)  # cup

    recipe1 = Recipe.create!(
      name: "Recipe with diced tomatoes",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe1.recipe_ingredients.create!(
      ingredient: diced_tomatoes,
      numerator: 2,
      denominator: 1,
      measurement_unit: unit
    )

    recipe2 = Recipe.create!(
      name: "Recipe with whole tomatoes",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe2.recipe_ingredients.create!(
      ingredient: whole_tomatoes,
      numerator: 1,
      denominator: 1,
      measurement_unit: unit
    )

    meal_plan.meal_plan_recipes.create!(recipe: recipe1)
    meal_plan.meal_plan_recipes.create!(recipe: recipe2)

    tomato_ingredients = MealPlanIngredient.where(
      meal_plan_id: meal_plan.id,
      name: "tomatoes"
    )

    assert_equal 2, tomato_ingredients.count, "Should have 2 separate rows for different preparation"

    diced = tomato_ingredients.find { |i| i.preparation_style == "diced" }
    whole = tomato_ingredients.find { |i| i.preparation_style == "whole" }

    assert_not_nil diced, "Should have diced tomatoes"
    assert_not_nil whole, "Should have whole tomatoes"
  end

  def test_aggregates_quantities_for_same_ingredient_packaging_and_preparation
    meal_plan = meal_plans(:one)

    # Create one ingredient used in two recipes
    canned_diced_tomatoes = Ingredient.find_or_create_by!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    unit = measurement_units(:two)  # cup

    recipe1 = Recipe.create!(
      name: "Recipe 1",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe1.recipe_ingredients.create!(
      ingredient: canned_diced_tomatoes,
      numerator: 2,
      denominator: 1,
      measurement_unit: unit
    )

    recipe2 = Recipe.create!(
      name: "Recipe 2",
      serving_size: 4,
      duration_minutes: 30,
      difficulty_level: "easy"
    )
    recipe2.recipe_ingredients.create!(
      ingredient: canned_diced_tomatoes,
      numerator: 1,
      denominator: 1,
      measurement_unit: unit
    )

    meal_plan.meal_plan_recipes.create!(recipe: recipe1)
    meal_plan.meal_plan_recipes.create!(recipe: recipe2)

    tomato_ingredients = MealPlanIngredient.where(
      meal_plan_id: meal_plan.id,
      name: "tomatoes"
    )

    assert_equal 1, tomato_ingredients.count, "Should aggregate same ingredient/packaging/preparation into 1 row"

    ingredient = tomato_ingredients.first
    assert_equal "canned", ingredient.packaging_form
    assert_equal "diced", ingredient.preparation_style
    # Quantity should be 3.0 (2 + 1)
    assert_equal 3.0, ingredient.quantity.to_f
  end
end
