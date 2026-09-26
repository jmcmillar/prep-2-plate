require "test_helper"

class RecipeImports::BuildRecipeTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  PARSED = {
    name: "Test Soup",
    description: "A soup.",
    yield: [ "Serves 4-6" ],
    total_time: nil,
    prep_time: 10,
    cook_time: 25,
    instructions: [ "Chop.", "Simmer." ],
    ingredients: [ "2 cups zzbroth", "1 zzonion, diced", "", "1/2 tsp zzsalt" ],
    image_url: nil
  }.freeze

  def setup
    @units = create_parser_units
    @recipe_import = RecipeImport.new(url: "https://example.com/soup")
  end

  def test_maps_recipe_fields
    recipe = build

    assert_equal "Test Soup", recipe.name
    assert_equal 4, recipe.serving_size
    assert_equal 35, recipe.duration_minutes
    assert_equal @recipe_import, recipe.recipe_import
    assert_equal [ "Chop.", "Simmer." ], recipe.recipe_instructions.map(&:instruction)
    assert_equal [ 1, 2 ], recipe.recipe_instructions.map(&:step_number)
  end

  def test_builds_ingredients_with_fractional_quantities
    ingredients = build.recipe_ingredients

    assert_equal 3, ingredients.size
    assert_equal [ 2, 1 ], [ ingredients.first.numerator, ingredients.first.denominator ]
    assert_equal [ 1, 2 ], [ ingredients.last.numerator, ingredients.last.denominator ]
    assert_equal @units["teaspoon"].id, ingredients.last.measurement_unit_id
    assert_equal "diced", ingredients.second.notes
  end

  def test_does_not_create_ingredients_until_saved
    recipe = nil

    assert_no_difference("Ingredient.count") { recipe = build }
    assert_difference("Ingredient.count", 3) { assert recipe.save }
    assert_equal "diced", Ingredient.find_by(name: "zzonion").preparation_style
  end

  def test_failed_save_leaves_no_orphan_ingredients
    recipe = build(PARSED.merge(name: nil))

    assert_no_difference("Ingredient.count") { assert_not recipe.save }
  end

  def test_can_skip_ingredients
    assert_empty build(PARSED, with_ingredients: false).recipe_ingredients
  end

  private

  def build(parsed = PARSED, **options)
    RecipeImports::BuildRecipe.call(parsed, recipe_import: @recipe_import, attach_image: false, **options)
  end
end
