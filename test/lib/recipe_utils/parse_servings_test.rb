require "test_helper"

class RecipeUtils::ParseServingsTest < ActiveSupport::TestCase
  def test_reads_integers_and_strings
    assert_equal 4, RecipeUtils::ParseServings.call(4)
    assert_equal 4, RecipeUtils::ParseServings.call("Serves 4-6")
    assert_equal 12, RecipeUtils::ParseServings.call("Makes 12 cookies")
  end

  def test_reads_first_usable_array_value
    assert_equal 6, RecipeUtils::ParseServings.call([ "", "6 servings" ])
  end

  def test_returns_nil_when_no_number
    assert_nil RecipeUtils::ParseServings.call("One loaf")
    assert_nil RecipeUtils::ParseServings.call(nil)
    assert_nil RecipeUtils::ParseServings.call("0")
  end
end
