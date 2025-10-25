require "test_helper"

class ParseIngredientTest < ActiveSupport::TestCase
  def setup
    # Create measurement units and aliases for testing
    @cup_unit = MeasurementUnit.create!(name: "cup")
    @tablespoon_unit = MeasurementUnit.create!(name: "tablespoon")
    @teaspoon_unit = MeasurementUnit.create!(name: "teaspoon")

    # Create aliases
    MeasurementUnitAlias.create!(measurement_unit: @cup_unit, name: "c")
    MeasurementUnitAlias.create!(measurement_unit: @cup_unit, name: "C")
    MeasurementUnitAlias.create!(measurement_unit: @tablespoon_unit, name: "tbsp")
    MeasurementUnitAlias.create!(measurement_unit: @tablespoon_unit, name: "T")
    MeasurementUnitAlias.create!(measurement_unit: @teaspoon_unit, name: "tsp")
    MeasurementUnitAlias.create!(measurement_unit: @teaspoon_unit, name: "t")
  end

  def teardown
    MeasurementUnitAlias.destroy_all
    MeasurementUnit.destroy_all
  end

  test "parses basic ingredient with quantity, unit, and name" do
    ingredient = "2 cups flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "flour", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  test "parses ingredient with fractional quantity" do
    ingredient = "1/2 cup sugar"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "sugar", result[:ingredient_name]
  end

  test "parses ingredient with decimal quantity" do
    ingredient = "2.5 tablespoons olive oil"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2.5", result[:quantity]
    assert_equal @tablespoon_unit.id, result[:measurement_unit_id]
    assert_equal "olive oil", result[:ingredient_name]
  end

  test "excludes measurement unit from ingredient name" do
    ingredient = "2 cups all-purpose flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    # Should exclude "cups", "cup", "c", "C" from the ingredient name
    assert_equal "allpurpose flour", result[:ingredient_name]
    refute_includes result[:ingredient_name], "cup"
    refute_includes result[:ingredient_name], "cups"
  end

  test "excludes measurement unit aliases from ingredient name" do
    ingredient = "1 tsp vanilla extract"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @teaspoon_unit.id, result[:measurement_unit_id]
    # Should exclude "tsp", "teaspoon", "teaspoons", "t" from ingredient name
    assert_equal "vanilla extract", result[:ingredient_name]
    refute_includes result[:ingredient_name], "tsp"
  end

  test "parses ingredient with parenthetical notes" do
    ingredient = "2 cups flour (sifted)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "flour", result[:ingredient_name]
    assert_equal "sifted", result[:ingredient_notes]
  end

  test "parses ingredient with comma-separated notes" do
    ingredient = "1 large onion, diced, fresh"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "large onion", result[:ingredient_name]
    assert_equal "diced, fresh", result[:ingredient_notes]
  end

  test "excludes notes from ingredient name" do
    ingredient = "2 cups basil, fresh (chopped)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "basil", result[:ingredient_name]
    assert_equal "fresh, chopped", result[:ingredient_notes]
    # Should exclude both "fresh" (from comma notes) and "chopped" (from parenthetical)
    refute_includes result[:ingredient_name], "fresh"
    refute_includes result[:ingredient_name], "chopped"
  end

  test "handles ingredient with no measurement unit" do
    ingredient = "1 large onion"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "large onion", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  test "handles ingredient with no quantity" do
    ingredient = "salt to taste"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "salt to taste", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  test "handles complex ingredient with all components" do
    ingredient = "2 1/4 cups basil leaves, fresh, chopped (organic)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2 1/4", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    # Should exclude: cups, cup, c, C (unit aliases), fresh, chopped (comma notes), organic (parenthetical)
    assert_equal "basil leaves", result[:ingredient_name]
    assert_equal "fresh, chopped, organic", result[:ingredient_notes]
  end

  test "handles empty ingredient string" do
    ingredient = ""
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  test "quantity? method returns true when quantity present" do
    parser = ParseIngredient.new("2 cups flour")
    assert parser.send(:quantity?)
  end

  test "quantity? method returns false when no quantity" do
    parser = ParseIngredient.new("salt to taste")
    refute parser.send(:quantity?)
  end

  test "unit_parser is memoized" do
    parser = ParseIngredient.new("2 cups flour")
    first_call = parser.send(:unit_parser)
    second_call = parser.send(:unit_parser)
    
    assert_same first_call, second_call
  end

  test "exclude_from_name combines notes and unit aliases" do
    ingredient = "2 cups fresh basil, chopped"
    parser = ParseIngredient.new(ingredient)
    excludes = parser.send(:exclude_from_name)

    # Should include unit aliases and notes
    assert_includes excludes, "cup"
    assert_includes excludes, "cups" 
    assert_includes excludes, "c"
    assert_includes excludes, "C"
    assert_includes excludes, "chopped"
  end

  test "handles ingredient with mixed case units" do
    ingredient = "2 CUPS Flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @cup_unit.id, result[:measurement_unit_id]
    # The ingredient name should exclude the unit regardless of case
    assert_equal "Flour", result[:ingredient_name]
  end

  test "handles unicode characters in ingredient" do
    ingredient = "1 cup café beans"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "café beans", result[:ingredient_name]
  end

  test "handles ingredient with multiple parenthetical notes" do
    ingredient = "2 cups flour (sifted) (organic)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "flour", result[:ingredient_name]
    assert_equal "sifted, organic", result[:ingredient_notes]
  end
end
