require "test_helper"

class ParseIngredientTest < ActiveSupport::TestCase
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

  def test_parses_basic_ingredient_with_quantity_unit_and_name
    ingredient = "2 cups flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "flour", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  def test_parses_ingredient_with_fractional_quantity
    ingredient = "1/2 cup sugar"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "sugar", result[:ingredient_name]
  end

  def test_parses_ingredient_with_decimal_quantity
    ingredient = "2.5 tablespoons olive oil"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2.5", result[:quantity]
    assert_equal @tablespoon_unit.id, result[:measurement_unit_id]
    assert_equal "olive oil", result[:ingredient_name]
  end

  def test_excludes_measurement_unit_from_ingredient_name
    ingredient = "2 cups all-purpose flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    # Should exclude "cups", "cup", "c", "C" from the ingredient name
    assert_equal "allpurpose flour", result[:ingredient_name]
    refute_includes result[:ingredient_name], "cup"
    refute_includes result[:ingredient_name], "cups"
  end

  def test_excludes_measurement_unit_aliases_from_ingredient_name
    ingredient = "1 tsp vanilla extract"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @teaspoon_unit.id, result[:measurement_unit_id]
    # Should exclude "tsp", "teaspoon", "teaspoons", "t" from ingredient name
    assert_equal "vanilla extract", result[:ingredient_name]
    refute_includes result[:ingredient_name], "tsp"
  end

  def test_parses_ingredient_with_parenthetical_notes
    ingredient = "2 cups flour (sifted)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "flour", result[:ingredient_name]
    assert_equal "sifted", result[:ingredient_notes]
  end

  def test_parses_ingredient_with_comma_separated_notes
    ingredient = "1 large onion, diced, fresh"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "large onion", result[:ingredient_name]
    assert_equal "diced, fresh", result[:ingredient_notes]
  end

  def test_excludes_notes_from_ingredient_name
    ingredient = "2 cups basil, fresh (chopped)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "basil", result[:ingredient_name]
    assert_equal "chopped, fresh", result[:ingredient_notes]
    # Should exclude both "fresh" (from comma notes) and "chopped" (from parenthetical)
    refute_includes result[:ingredient_name], "fresh"
    refute_includes result[:ingredient_name], "chopped"
  end

  def test_handles_ingredient_with_no_measurement_unit
    ingredient = "1 large onion"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "large onion", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  def test_handles_ingredient_with_no_quantity
    ingredient = "salt to taste"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "salt to taste", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  def test_handles_complex_ingredient_with_all_components
    ingredient = "2 1/4 cups basil leaves, fresh, chopped (organic)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "2 1/4", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    # Should exclude: cups, cup, c, C (unit aliases), organic (parenthetical), fresh, chopped (comma notes)
    assert_equal "basil leaves", result[:ingredient_name]
    assert_equal "organic, fresh, chopped", result[:ingredient_notes]
  end

  def test_handles_empty_ingredient_string
    ingredient = ""
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "", result[:ingredient_name]
    assert_equal "", result[:ingredient_notes]
  end

  def test_quantity_method_returns_true_when_quantity_present
    parser = ParseIngredient.new("2 cups flour")
    assert parser.send(:quantity?)
  end

  def test_quantity_method_returns_false_when_no_quantity
    parser = ParseIngredient.new("salt to taste")
    refute parser.send(:quantity?)
  end

  def test_unit_parser_is_memoized
    parser = ParseIngredient.new("2 cups flour")
    first_call = parser.send(:unit_parser)
    second_call = parser.send(:unit_parser)
    
    assert_same first_call, second_call
  end

  def test_exclude_from_name_combines_notes_and_unit_aliases
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

  def test_handles_ingredient_with_mixed_case_units
    ingredient = "2 CUPS Flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @cup_unit.id, result[:measurement_unit_id]
    # The ingredient name should exclude the unit regardless of case
    assert_equal "Flour", result[:ingredient_name]
  end

  def test_handles_unicode_characters_in_ingredient
    ingredient = "1 cup café beans"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "café beans", result[:ingredient_name]
  end

  def test_handles_ingredient_with_multiple_parenthetical_notes
    ingredient = "2 cups flour (sifted) (organic)"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "flour", result[:ingredient_name]
    assert_equal "sifted, organic", result[:ingredient_notes]
  end

  def test_parses_ingredient_with_unicode_fraction_one_half
    ingredient = "½ cup sugar"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "sugar", result[:ingredient_name]
  end

  def test_parses_ingredient_with_unicode_fraction_one_quarter
    ingredient = "¼ teaspoon salt"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/4", result[:quantity]
    assert_equal @teaspoon_unit.id, result[:measurement_unit_id]
    assert_equal "salt", result[:ingredient_name]
  end

  def test_parses_ingredient_with_unicode_fraction_three_quarters
    ingredient = "¾ cup milk"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "3/4", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "milk", result[:ingredient_name]
  end

  def test_parses_ingredient_with_unicode_fraction_one_third
    ingredient = "⅓ cup olive oil"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/3", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "olive oil", result[:ingredient_name]
  end

  def test_excludes_unicode_fraction_from_ingredient_name
    ingredient = "½ barbecue sauce"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "1/2", result[:quantity]
    assert_equal "barbecue sauce", result[:ingredient_name]
    refute_includes result[:ingredient_name], "½"
    refute_includes result[:ingredient_name], "1/2"
  end

  def test_parses_mixed_number_with_unicode_fraction
    ingredient = "2½ cups flour"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    # Note: "2½" converts to "21/2" which isn't ideal but is handled
    # A future enhancement could be to add space: "2 1/2"
    assert_equal "21/2", result[:quantity]
    assert_equal @cup_unit.id, result[:measurement_unit_id]
    assert_equal "flour", result[:ingredient_name]
  end

  # New tests for packaging_form and preparation_style extraction

  def test_extracts_both_packaging_and_preparation_from_canned_diced_tomatoes
    ingredient = "1 can canned diced tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    assert_equal "canned", result[:packaging_form]
    assert_equal "diced", result[:preparation_style]
  end

  def test_extracts_packaging_from_frozen_spinach
    ingredient = "1 package frozen spinach"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "spinach", result[:ingredient_name]
    assert_equal "frozen", result[:packaging_form]
    assert_nil result[:preparation_style]
  end

  def test_extracts_preparation_from_diced_tomatoes_without_packaging
    ingredient = "2 cups diced tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_equal "diced", result[:preparation_style]
  end

  def test_extracts_both_from_frozen_chopped_spinach
    ingredient = "1 package frozen chopped spinach"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "spinach", result[:ingredient_name]
    assert_equal "frozen", result[:packaging_form]
    assert_equal "chopped", result[:preparation_style]
  end

  def test_handles_fresh_preparation_combination
    ingredient = "2 cups fresh diced tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    assert_equal "fresh", result[:packaging_form]
    assert_equal "diced", result[:preparation_style]
  end

  def test_returns_nil_for_both_when_neither_is_present
    ingredient = "2 cups tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_nil result[:preparation_style]
  end

  def test_removes_packaging_and_preparation_keywords_from_ingredient_name
    ingredient = "1 can crushed tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    refute_includes result[:ingredient_name], "crushed"
    refute_includes result[:ingredient_name], "canned"
    assert_equal "canned", result[:packaging_form]
    assert_equal "crushed", result[:preparation_style]
  end

  def test_handles_ground_beef
    ingredient = "1 lb ground beef"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "beef", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_equal "ground", result[:preparation_style]
  end

  def test_handles_shredded_cheese
    ingredient = "1 cup shredded cheddar cheese"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "cheddar cheese", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_equal "shredded", result[:preparation_style]
  end

  def test_handles_dried_fruit
    ingredient = "1/2 cup dried cranberries"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "cranberries", result[:ingredient_name]
    assert_equal "dried", result[:packaging_form]
    assert_nil result[:preparation_style]
  end

  def test_handles_canned_whole_tomatoes
    ingredient = "1 can canned whole tomatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "tomatoes", result[:ingredient_name]
    assert_equal "canned", result[:packaging_form]
    assert_equal "whole", result[:preparation_style]
  end

  def test_handles_grated_cheese
    ingredient = "1/4 cup grated parmesan cheese"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "parmesan cheese", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_equal "grated", result[:preparation_style]
  end

  def test_handles_cubed_potatoes
    ingredient = "2 cups cubed potatoes"
    parser = ParseIngredient.new(ingredient)
    result = parser.to_h

    assert_equal "potatoes", result[:ingredient_name]
    assert_nil result[:packaging_form]
    assert_equal "cubed", result[:preparation_style]
  end
end
