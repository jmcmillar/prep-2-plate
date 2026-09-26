require "test_helper"

class RecipeUtils::UnitLookupTest < ActiveSupport::TestCase
  include MeasurementUnitHelper

  def setup
    @units = create_parser_units
    @lookup = RecipeUtils::UnitLookup.new
  end

  def test_single_letter_aliases_are_case_sensitive
    assert_equal @units["tablespoon"], @lookup.find("T")
    assert_equal @units["teaspoon"], @lookup.find("t")
  end

  def test_longer_spellings_are_case_insensitive_and_ignore_periods
    assert_equal @units["cup"], @lookup.find("Cups")
    assert_equal @units["ounce"], @lookup.find("oz.")
  end

  def test_match_prefix_prefers_longest_unit
    match = @lookup.match_prefix(%w[fl oz vanilla])

    assert_equal @units["fluid ounce"], match.unit
    assert_equal 2, match.word_count
  end

  def test_match_prefix_only_checks_leading_words
    assert_nil @lookup.match_prefix(%w[onion cut in half])
  end

  def test_alias_names_include_name_plural_and_aliases
    names = @lookup.alias_names(@units["cup"])

    assert_includes names, "cup"
    assert_includes names, "cups"
    assert_includes names, "c"
  end
end
