require "test_helper"

class RecipeUtils::ParseUnitTest < ActiveSupport::TestCase
  def setup
    # Create measurement units and aliases for testing
    @cup_unit = MeasurementUnit.create!(name: "cup")
    @tablespoon_unit = MeasurementUnit.create!(name: "tablespoon")
    @teaspoon_unit = MeasurementUnit.create!(name: "teaspoon")
    @pound_unit = MeasurementUnit.create!(name: "pound")

    # Create aliases
    MeasurementUnitAlias.create!(measurement_unit: @cup_unit, name: "c")
    MeasurementUnitAlias.create!(measurement_unit: @cup_unit, name: "C")
    MeasurementUnitAlias.create!(measurement_unit: @tablespoon_unit, name: "tbsp")
    MeasurementUnitAlias.create!(measurement_unit: @tablespoon_unit, name: "T")
    MeasurementUnitAlias.create!(measurement_unit: @teaspoon_unit, name: "tsp")
    MeasurementUnitAlias.create!(measurement_unit: @teaspoon_unit, name: "t")
    MeasurementUnitAlias.create!(measurement_unit: @pound_unit, name: "lb")
    MeasurementUnitAlias.create!(measurement_unit: @pound_unit, name: "lbs")
  end

  def teardown
    MeasurementUnitAlias.destroy_all
    MeasurementUnit.destroy_all
  end

  test "parses ingredient with exact unit name match" do
    ingredient = "2 cups flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
    assert_includes result.alias_names, "cups"
    assert_includes result.alias_names, "c"
    assert_includes result.alias_names, "C"
  end

  test "parses ingredient with plural unit name" do
    ingredient = "3 tablespoons olive oil"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @tablespoon_unit.id, result.id
    assert_includes result.alias_names, "tablespoon"
    assert_includes result.alias_names, "tablespoons"
    assert_includes result.alias_names, "tbsp"
    assert_includes result.alias_names, "T"
  end

  test "parses ingredient with unit alias" do
    ingredient = "1 tsp vanilla extract"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @teaspoon_unit.id, result.id
    assert_includes result.alias_names, "teaspoon"
    assert_includes result.alias_names, "teaspoons"
    assert_includes result.alias_names, "tsp"
    assert_includes result.alias_names, "t"
  end

  test "parses ingredient with multiple aliases present" do
    ingredient = "2 lbs ground beef"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @pound_unit.id, result.id
    assert_includes result.alias_names, "pound"
    assert_includes result.alias_names, "pounds"
    assert_includes result.alias_names, "lb"
    assert_includes result.alias_names, "lbs"
  end

  test "handles ingredient with no recognizable unit" do
    ingredient = "1 large onion, diced"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  test "handles ingredient with only numbers and spaces" do
    ingredient = "2.5"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  test "handles empty ingredient string" do
    ingredient = ""
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  test "handles ingredient with fractions and decimals" do
    ingredient = "1.5 cups sugar"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  test "handles ingredient with mixed case unit" do
    ingredient = "2 CUPS flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  test "handles ingredient with unit at different position" do
    ingredient = "olive oil, 3 tablespoons"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @tablespoon_unit.id, result.id
    assert_includes result.alias_names, "tablespoon"
  end

  test "returns first match when multiple units could match" do
    # Create a scenario where multiple units might match
    ingredient = "1 cup tablespoon mixture"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    # Should match one of the units (order depends on database query)
    assert_not_nil result.id
    assert_includes [@cup_unit.id, @tablespoon_unit.id], result.id
  end

  test "ingredient_words method strips numbers and extracts words correctly" do
    parser = RecipeUtils::ParseUnit.new("2.5 cups all-purpose flour")
    words = parser.ingredient_words

    assert_includes words, "cups"
    assert_includes words, "all-purpose"
    assert_includes words, "flour"
    refute_includes words, "2.5"
  end

  test "ingredient_words handles complex ingredient descriptions" do
    parser = RecipeUtils::ParseUnit.new("1/2 cup fresh basil leaves, chopped")
    words = parser.ingredient_words

    assert_includes words, "cup"
    assert_includes words, "fresh"
    assert_includes words, "basil"
    assert_includes words, "leaves,"
    assert_includes words, "chopped"
    refute_includes words, "1/2"
  end

  test "Data struct can be created with new syntax" do
    data = RecipeUtils::ParseUnit::Data.new(1, ["cup", "c"])
    
    assert_equal 1, data.id
    assert_equal ["cup", "c"], data.alias_names
  end

  test "Data struct can be created with bracket syntax" do
    data = RecipeUtils::ParseUnit::Data[2, ["tbsp", "T"]]
    
    assert_equal 2, data.id
    assert_equal ["tbsp", "T"], data.alias_names
  end

  test "handles ingredient with unicode characters" do
    ingredient = "1 cup café special blend"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  test "possible_unit_match returns array of matching units" do
    parser = RecipeUtils::ParseUnit.new("2 cups flour")
    matches = parser.possible_unit_match

    assert_includes matches, @cup_unit
    assert_equal 1, matches.length
  end

  test "possible_unit_match returns empty array for no matches" do
    parser = RecipeUtils::ParseUnit.new("1 large onion")
    matches = parser.possible_unit_match

    assert_empty matches
  end

  test "alias_names returns empty array when no unit match" do
    parser = RecipeUtils::ParseUnit.new("1 large onion")
    aliases = parser.alias_names

    assert_empty aliases
  end

  test "memoization of possible_unit_match" do
    parser = RecipeUtils::ParseUnit.new("2 cups flour")
    
    first_call = parser.possible_unit_match
    second_call = parser.possible_unit_match
    
    # Should return the same object (memoized)
    assert_same first_call, second_call
  end

  test "memoization of grouped_by_measurement" do
    parser = RecipeUtils::ParseUnit.new("2 cups flour")
    
    first_call = parser.grouped_by_measurement
    second_call = parser.grouped_by_measurement
    
    # Should return the same object (memoized)
    assert_same first_call, second_call
  end

  test "to_data class method works same as instance method" do
    ingredient = "2 cups flour"
    
    class_result = RecipeUtils::ParseUnit.to_data(ingredient)
    instance_result = RecipeUtils::ParseUnit.new(ingredient).to_data

    assert_equal class_result.id, instance_result.id
    assert_equal class_result.alias_names, instance_result.alias_names
  end

  test "handles ingredient with punctuation in unit context" do
    ingredient = "2 cups, all-purpose flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  test "case insensitive matching with aliases" do
    ingredient = "1 TSP vanilla"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @teaspoon_unit.id, result.id
    assert_includes result.alias_names, "tsp"
  end
end
