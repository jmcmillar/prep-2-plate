require "test_helper"

class RecipeUtils::ParseQuantityTest < ActiveSupport::TestCase
  def test_parses_whole_numbers
    result = RecipeUtils::ParseQuantity.new("2").to_value
    assert_equal 2, result.numerator
    assert_equal 1, result.denominator
  end

  def test_parses_fractions
    result = RecipeUtils::ParseQuantity.new("1/2").to_value
    assert_equal 1, result.numerator
    assert_equal 2, result.denominator
  end

  def test_parses_mixed_numbers
    result = RecipeUtils::ParseQuantity.new("1 1/2").to_value
    assert_equal 3, result.numerator
    assert_equal 2, result.denominator
  end

  def test_parses_simple_decimals
    result = RecipeUtils::ParseQuantity.new("0.5").to_value
    assert_equal 1, result.numerator
    assert_equal 2, result.denominator
  end

  def test_parses_decimal_to_third
    result = RecipeUtils::ParseQuantity.new("0.33333334326744").to_value
    assert_equal 1, result.numerator
    assert_equal 3, result.denominator
  end

  def test_parses_decimal_to_quarter
    result = RecipeUtils::ParseQuantity.new("0.25").to_value
    assert_equal 1, result.numerator
    assert_equal 4, result.denominator
  end

  def test_parses_decimal_to_three_quarters
    result = RecipeUtils::ParseQuantity.new("0.75").to_value
    assert_equal 3, result.numerator
    assert_equal 4, result.denominator
  end

  def test_parses_mixed_decimal
    result = RecipeUtils::ParseQuantity.new("1.5").to_value
    assert_equal 3, result.numerator
    assert_equal 2, result.denominator
  end

  def test_numerator_and_denominator_fit_in_integer_range
    # Test that even very precise decimals don't create huge numbers
    result = RecipeUtils::ParseQuantity.new("0.33333334326744").to_value

    # Should fit in a 4-byte signed integer (-2147483648 to 2147483647)
    assert result.numerator < 2147483647
    assert result.denominator < 2147483647
    assert result.numerator > -2147483648
    assert result.denominator > -2147483648
  end

  def test_multiple_decimal_values_stay_in_range
    test_cases = [
      "0.33333334326744",
      "1.5",
      "0.75",
      "2",
      "0.5",
      "1/3",
      "0.25",
      "1.5"
    ]

    test_cases.each do |quantity|
      result = RecipeUtils::ParseQuantity.new(quantity).to_value
      assert result.numerator < 2147483647, "Numerator #{result.numerator} too large for #{quantity}"
      assert result.denominator < 2147483647, "Denominator #{result.denominator} too large for #{quantity}"
    end
  end
end
