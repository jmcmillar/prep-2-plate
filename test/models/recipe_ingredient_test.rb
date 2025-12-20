require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  def setup
    @recipe = recipes(:one)
    @cup_unit = measurement_units(:two)
  end

  def test_creates_ingredient_with_packaging_and_preparation
    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "tomatoes"
    recipe_ingredient.packaging_form = "canned"
    recipe_ingredient.preparation_style = "diced"

    assert recipe_ingredient.save

    ingredient = recipe_ingredient.ingredient
    assert_equal "tomatoes", ingredient.name
    assert_equal "canned", ingredient.packaging_form
    assert_equal "diced", ingredient.preparation_style
  end

  def test_creates_ingredient_with_only_packaging
    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "spinach"
    recipe_ingredient.packaging_form = "frozen"

    assert recipe_ingredient.save

    ingredient = recipe_ingredient.ingredient
    assert_equal "spinach", ingredient.name
    assert_equal "frozen", ingredient.packaging_form
    assert_nil ingredient.preparation_style
  end

  def test_creates_ingredient_with_only_preparation
    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "beef"
    recipe_ingredient.preparation_style = "ground"

    assert recipe_ingredient.save

    ingredient = recipe_ingredient.ingredient
    assert_equal "beef", ingredient.name
    assert_nil ingredient.packaging_form
    assert_equal "ground", ingredient.preparation_style
  end

  def test_creates_ingredient_with_neither_packaging_nor_preparation
    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "salt"

    assert recipe_ingredient.save

    ingredient = recipe_ingredient.ingredient
    assert_equal "salt", ingredient.name
    assert_nil ingredient.packaging_form
    assert_nil ingredient.preparation_style
  end

  def test_finds_existing_ingredient_with_same_packaging_and_preparation
    # Create initial ingredient
    existing = Ingredient.create!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "tomatoes"
    recipe_ingredient.packaging_form = "canned"
    recipe_ingredient.preparation_style = "diced"

    assert recipe_ingredient.save

    # Should reuse existing ingredient
    assert_equal existing.id, recipe_ingredient.ingredient_id
    assert_equal 1, Ingredient.where(name: "tomatoes", packaging_form: "canned", preparation_style: "diced").count
  end

  def test_creates_new_ingredient_when_packaging_differs
    # Create initial ingredient
    Ingredient.create!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "tomatoes"
    recipe_ingredient.packaging_form = "fresh"
    recipe_ingredient.preparation_style = "diced"

    assert recipe_ingredient.save

    # Should create a new ingredient
    assert_equal 2, Ingredient.where(name: "tomatoes").count
    assert_equal "fresh", recipe_ingredient.ingredient.packaging_form
  end

  def test_creates_new_ingredient_when_preparation_differs
    # Create initial ingredient
    Ingredient.create!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    recipe_ingredient = RecipeIngredient.new(
      recipe: @recipe,
      measurement_unit: @cup_unit,
      numerator: 1,
      denominator: 1
    )
    recipe_ingredient.ingredient_name = "tomatoes"
    recipe_ingredient.packaging_form = "canned"
    recipe_ingredient.preparation_style = "crushed"

    assert recipe_ingredient.save

    # Should create a new ingredient
    assert_equal 2, Ingredient.where(name: "tomatoes").count
    assert_equal "crushed", recipe_ingredient.ingredient.preparation_style
  end

  def test_delegates_packaging_form_to_ingredient
    ingredient = Ingredient.create!(
      name: "tomatoes",
      packaging_form: "canned"
    )

    recipe_ingredient = RecipeIngredient.create!(
      recipe: @recipe,
      ingredient: ingredient,
      numerator: 1,
      denominator: 1
    )

    assert_equal "canned", recipe_ingredient.ingredient_packaging_form
  end

  def test_delegates_preparation_style_to_ingredient
    ingredient = Ingredient.create!(
      name: "tomatoes",
      preparation_style: "diced"
    )

    recipe_ingredient = RecipeIngredient.create!(
      recipe: @recipe,
      ingredient: ingredient,
      numerator: 1,
      denominator: 1
    )

    assert_equal "diced", recipe_ingredient.ingredient_preparation_style
  end

  def test_delegates_display_name_to_ingredient
    ingredient = Ingredient.create!(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )

    recipe_ingredient = RecipeIngredient.create!(
      recipe: @recipe,
      ingredient: ingredient,
      numerator: 1,
      denominator: 1
    )

    assert_equal "Canned Diced tomatoes", recipe_ingredient.ingredient_display_name
  end
end
