require "test_helper"

class ParseIngredientTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  # line => expected attributes (unit given by name; omitted keys must be blank)
  CASES = {
    "2 cups flour" => { quantity: "2", unit: "cup", name: "flour" },
    "1/2 cup sugar" => { quantity: "1/2", unit: "cup", name: "sugar" },
    "2.5 tablespoons olive oil" => { quantity: "2.5", unit: "tablespoon", name: "olive oil" },
    ".5 cup water" => { quantity: "0.5", unit: "cup", name: "water" },
    "2 cups all-purpose flour" => { quantity: "2", unit: "cup", name: "all-purpose flour" },
    "1½ cups whole milk, warmed" => { quantity: "1 1/2", unit: "cup", name: "whole milk", notes: "warmed" },
    "1 1⁄2 teaspoons baking powder" => { quantity: "1 1/2", unit: "teaspoon", name: "baking powder" },
    "1 &frac12; cups sugar" => { quantity: "1 1/2", unit: "cup", name: "sugar" },
    "1 medium onion, cut in half" => { quantity: "1", unit: "medium", name: "onion", notes: "cut in half" },
    "2-3 cloves garlic, minced" => { quantity: "2", unit: "clove", name: "garlic", prep: "minced", notes: "2-3, minced" },
    "1 (14.5 oz) can diced tomatoes" => { quantity: "1", unit: "can", name: "tomato", packaging: "canned", prep: "diced", notes: "14.5 oz" },
    "1 tsp ground cloves" => { quantity: "1", unit: "teaspoon", name: "clove", prep: "ground" },
    "2 T sugar" => { quantity: "2", unit: "tablespoon", name: "sugar" },
    "2 t salt" => { quantity: "2", unit: "teaspoon", name: "salt" },
    "salt and pepper to taste" => { name: "salt and pepper", notes: "to taste" },
    "3 eggs" => { quantity: "3", name: "egg" },
    "1 lb ground beef" => { quantity: "1", unit: "pound", name: "ground beef" },
    "¼ cup finely chopped parsley" => { quantity: "1/4", unit: "cup", name: "parsley", prep: "chopped", notes: "finely chopped" },
    "a pinch of salt" => { quantity: "1", unit: "pinch", name: "salt" },
    "2 tablespoons extra-virgin olive oil, divided" => { quantity: "2", unit: "tablespoon", name: "extra-virgin olive oil", notes: "divided" },
    "4 boneless, skinless chicken breasts" => { quantity: "4", name: "boneless skinless chicken breast" },
    "8 oz. cream cheese, softened" => { quantity: "8", unit: "ounce", name: "cream cheese", notes: "softened" },
    "1 package cream cheese" => { quantity: "1", unit: "package", name: "cream cheese" },
    "1 bottle red wine" => { quantity: "1", unit: "bottle", name: "red wine", packaging: "bottled" },
    "2 fl oz vanilla" => { quantity: "2", unit: "fluid ounce", name: "vanilla" },
    "2 cups frozen peas" => { quantity: "2", unit: "cup", name: "pea", packaging: "frozen" },
    "1 tablespoon molasses" => { quantity: "1", unit: "tablespoon", name: "molasses" },
    "6 olives" => { quantity: "6", name: "olive" },
    "3 carrots, peeled and sliced" => { quantity: "3", name: "carrot", prep: "sliced", notes: "peeled and sliced" },
    "200g golden caster sugar" => { quantity: "200", unit: "gram", name: "golden caster sugar" },
    "200g unsalted butter softened plus extra for the tins" => { quantity: "200", unit: "gram", name: "unsalted butter", notes: "plus extra for the tins, softened" },
    "100g milk chocolate chopped" => { quantity: "100", unit: "gram", name: "milk chocolate", prep: "chopped", notes: "chopped" },
    "1 lb. boneless, skinless chicken breast ($6.25)" => { quantity: "1", unit: "pound", name: "boneless skinless chicken breast" },
    "1/2 tsp baking soda / bi-carb ((optional, Note 1))" => { quantity: "1/2", unit: "teaspoon", name: "baking soda", notes: "optional, Note 1, or bi-carb" },
    "1 cup butter or margarine" => { quantity: "1", unit: "cup", name: "butter", notes: "or margarine" },
    "1/2 onion (, sliced (white, brown, yellow))" => { quantity: "1/2", name: "onion", prep: "sliced", notes: "sliced (white, brown, yellow)" }
  }.freeze

  def setup
    @units = create_parser_units
    @lookup = RecipeUtils::UnitLookup.new
  end

  CASES.each_with_index do |(line, expected), index|
    define_method("test_parses_case_#{index}_#{line.parameterize(separator: '_')}") do
      assert_parsed(line, **expected)
    end
  end

  def test_builds_its_own_unit_lookup_when_none_given
    assert_equal @units["cup"].id, ParseIngredient.new("2 cups flour").to_h[:measurement_unit_id]
  end

  def test_returns_blank_values_for_empty_input
    result = ParseIngredient.new("", unit_lookup: @lookup).to_h

    assert_equal "", result[:quantity]
    assert_nil result[:measurement_unit_id]
    assert_equal "", result[:ingredient_name]
  end

  def test_returns_all_keys_expected_by_callers
    keys = ParseIngredient.new("2 cups flour", unit_lookup: @lookup).to_h.keys

    assert_equal %i[quantity measurement_unit_id ingredient_name packaging_form preparation_style ingredient_notes].sort, keys.sort
  end

  private

  def assert_parsed(line, quantity: "", unit: nil, name:, packaging: nil, prep: nil, notes: "")
    result = ParseIngredient.new(line, unit_lookup: @lookup).to_h

    assert_equal quantity, result[:quantity], "quantity for #{line.inspect}"
    assert_value @units[unit]&.id, result[:measurement_unit_id], "unit for #{line.inspect}"
    assert_equal name, result[:ingredient_name], "name for #{line.inspect}"
    assert_value packaging, result[:packaging_form], "packaging for #{line.inspect}"
    assert_value prep, result[:preparation_style], "preparation for #{line.inspect}"
    assert_equal notes, result[:ingredient_notes], "notes for #{line.inspect}"
  end

  def assert_value(expected, actual, message)
    expected.nil? ? assert_nil(actual, message) : assert_equal(expected, actual, message)
  end
end
