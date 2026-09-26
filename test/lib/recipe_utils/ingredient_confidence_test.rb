require "test_helper"

class RecipeUtils::IngredientConfidenceTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  def setup
    create_parser_units
    @lookup = RecipeUtils::UnitLookup.new
  end

  def test_well_parsed_line_is_high
    assert_equal :high, score("2 cups flour").level
  end

  def test_unmeasured_staples_are_high
    assert_equal :high, score("salt and pepper to taste").level
    assert_equal :high, score("Freshly ground black pepper").level
  end

  def test_whole_milk_is_not_flagged_for_unit_word
    assert_equal :high, score("1 cup whole milk").level
  end

  def test_blank_name_is_low
    assert_includes score_hash({ ingredient_name: "", quantity: "1" }).reasons, :blank_name
  end

  def test_digits_in_name_are_low
    assert_includes score("Juice of 1 lemon").reasons, :digits_in_name
  end

  def test_unconsumed_unit_word_is_low
    assert_includes score_hash({ ingredient_name: "flour 2 tablespoons", quantity: "1" }).reasons, :unit_word_in_name
  end

  def test_long_name_is_low
    assert_includes score("2 cups of the very best local organic heirloom tomatoes").reasons, :long_name
  end

  def test_alternatives_split_by_parser_are_high
    assert_equal :high, score("1 cup butter or margarine").level
  end

  def test_alternatives_left_in_name_are_low
    assert_includes score_hash({ ingredient_name: "butter or margarine", quantity: "1" }).reasons, :alternatives_in_name
  end

  def test_nothing_measured_is_low
    assert_includes score("chicken stock").reasons, :nothing_measured
  end

  private

  def score(line)
    RecipeUtils::IngredientConfidence.call(line, ParseIngredient.new(line, unit_lookup: @lookup).to_h, unit_lookup: @lookup)
  end

  def score_hash(parsed)
    RecipeUtils::IngredientConfidence.call("", parsed, unit_lookup: @lookup)
  end
end
