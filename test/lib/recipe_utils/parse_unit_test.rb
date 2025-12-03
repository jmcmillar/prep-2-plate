require "test_helper"

class RecipeUtils::ParseUnitTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing data first
    MeasurementUnitAlias.destroy_all
    MeasurementUnit.destroy_all

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

  def test_parses_ingredient_with_exact_unit_name_match
    ingredient = "2 cups flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
    assert_includes result.alias_names, "cups"
    assert_includes result.alias_names, "c"
    assert_includes result.alias_names, "C"
  end

  def test_parses_ingredient_with_plural_unit_name
    ingredient = "3 tablespoons olive oil"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @tablespoon_unit.id, result.id
    assert_includes result.alias_names, "tablespoon"
    assert_includes result.alias_names, "tablespoons"
    assert_includes result.alias_names, "tbsp"
    assert_includes result.alias_names, "T"
  end

  def test_parses_ingredient_with_unit_alias
    ingredient = "1 tsp vanilla extract"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @teaspoon_unit.id, result.id
    assert_includes result.alias_names, "teaspoon"
    assert_includes result.alias_names, "teaspoons"
    assert_includes result.alias_names, "tsp"
    assert_includes result.alias_names, "t"
  end

  def test_parses_ingredient_with_multiple_aliases_present
    ingredient = "2 lbs ground beef"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @pound_unit.id, result.id
    assert_includes result.alias_names, "pound"
    assert_includes result.alias_names, "pounds"
    assert_includes result.alias_names, "lb"
    assert_includes result.alias_names, "lbs"
  end

  def test_handles_ingredient_with_no_recognizable_unit
    ingredient = "1 large onion, diced"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  def test_handles_ingredient_with_only_numbers_and_spaces
    ingredient = "2.5"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  def test_handles_empty_ingredient_string
    ingredient = ""
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_nil result.id
    assert_empty result.alias_names
  end

  def test_handles_ingredient_with_fractions_and_decimals
    ingredient = "1.5 cups sugar"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  def test_handles_ingredient_with_mixed_case_unit
    ingredient = "2 CUPS flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  def test_handles_ingredient_with_unit_at_different_position
    ingredient = "olive oil, 3 tablespoons"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @tablespoon_unit.id, result.id
    assert_includes result.alias_names, "tablespoon"
  end

  def test_returns_first_match_when_multiple_units_could_match
    # Create a scenario where multiple units might match
    ingredient = "1 cup tablespoon mixture"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    # Should match one of the units (order depends on database query)
    assert_not_nil result.id
    assert_includes [@cup_unit.id, @tablespoon_unit.id], result.id
  end

  def test_ingredient_words_method_strips_numbers_and_extracts_words_correctly
    parser = RecipeUtils::ParseUnit.new("2.5 cups all-purpose flour")
    words = parser.ingredient_words

    assert_includes words, "cups"
    assert_includes words, "allpurpose"  # Punctuation is stripped
    assert_includes words, "flour"
    refute_includes words, "2.5"
    refute_includes words, "all-purpose"  # Should not include punctuation
  end

  def test_ingredient_words_handles_complex_ingredient_descriptions
    parser = RecipeUtils::ParseUnit.new("1/2 cup fresh basil leaves, chopped")
    words = parser.ingredient_words

    assert_includes words, "cup"
    assert_includes words, "fresh"
    assert_includes words, "basil"
    assert_includes words, "leaves"  # Punctuation is stripped
    assert_includes words, "chopped"
    refute_includes words, "1/2"
    refute_includes words, "leaves,"  # Should not include punctuation
  end

  def test_data_struct_can_be_created_with_new_syntax
    data = RecipeUtils::ParseUnit::Data.new(1, ["cup", "c"])

    assert_equal 1, data.id
    assert_equal ["cup", "c"], data.alias_names
  end

  def test_data_struct_can_be_created_with_bracket_syntax
    data = RecipeUtils::ParseUnit::Data[2, ["tbsp", "T"]]

    assert_equal 2, data.id
    assert_equal ["tbsp", "T"], data.alias_names
  end

  def test_handles_ingredient_with_unicode_characters
    ingredient = "1 cup café special blend"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  def test_possible_unit_match_returns_array_of_matching_units
    parser = RecipeUtils::ParseUnit.new("2 cups flour")
    matches = parser.possible_unit_match

    assert_includes matches, @cup_unit
    assert_equal 1, matches.length
  end

  def test_possible_unit_match_returns_empty_array_for_no_matches
    parser = RecipeUtils::ParseUnit.new("1 large onion")
    matches = parser.possible_unit_match

    assert_empty matches
  end

  def test_alias_names_returns_empty_array_when_no_unit_match
    parser = RecipeUtils::ParseUnit.new("1 large onion")
    aliases = parser.alias_names

    assert_empty aliases
  end

  def test_memoization_of_possible_unit_match
    parser = RecipeUtils::ParseUnit.new("2 cups flour")

    first_call = parser.possible_unit_match
    second_call = parser.possible_unit_match

    # Should return the same object (memoized)
    assert_same first_call, second_call
  end

  def test_memoization_of_grouped_by_measurement
    parser = RecipeUtils::ParseUnit.new("2 cups flour")

    first_call = parser.grouped_by_measurement
    second_call = parser.grouped_by_measurement

    # Should return the same object (memoized)
    assert_same first_call, second_call
  end

  def test_to_data_class_method_works_same_as_instance_method
    ingredient = "2 cups flour"

    class_result = RecipeUtils::ParseUnit.to_data(ingredient)
    instance_result = RecipeUtils::ParseUnit.new(ingredient).to_data

    assert_equal class_result.id, instance_result.id
    assert_equal class_result.alias_names, instance_result.alias_names
  end

  def test_handles_ingredient_with_punctuation_in_unit_context
    ingredient = "2 cups, all-purpose flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cup"
  end

  def test_case_insensitive_matching_with_aliases
    ingredient = "1 TSP vanilla"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @teaspoon_unit.id, result.id
    assert_includes result.alias_names, "tsp"
  end

  def test_handles_unit_with_period
    ounce_unit = MeasurementUnit.find_or_create_by!(name: "ounce")
    MeasurementUnitAlias.find_or_create_by!(measurement_unit: ounce_unit, name: "oz")

    ingredient = "8 oz. cream cheese"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal ounce_unit.id, result.id
    assert_includes result.alias_names, "oz"
  end

  def test_handles_unit_with_hyphen_in_compound
    ounce_unit = MeasurementUnit.find_or_create_by!(name: "ounce")
    MeasurementUnitAlias.find_or_create_by!(measurement_unit: ounce_unit, name: "oz")

    ingredient = "1 8-ounce package cream cheese"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal ounce_unit.id, result.id
    assert_includes result.alias_names, "ounce"
  end

  def test_handles_multiple_punctuation_marks
    ingredient = "2 cups. flour"
    result = RecipeUtils::ParseUnit.to_data(ingredient)

    assert_equal @cup_unit.id, result.id
    assert_includes result.alias_names, "cups"
  end

  def test_ingredient_words_strips_all_punctuation_from_words
    parser = RecipeUtils::ParseUnit.new("8 oz. all-purpose flour (sifted)")
    words = parser.ingredient_words

    # Punctuation should be stripped from all words
    assert_includes words, "oz"
    assert_includes words, "allpurpose"
    assert_includes words, "flour"
    assert_includes words, "sifted"

    # Should not include punctuation
    refute_includes words, "oz."
    refute_includes words, "all-purpose"
  end
end
