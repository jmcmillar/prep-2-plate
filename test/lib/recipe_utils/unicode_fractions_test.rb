require "test_helper"

class RecipeUtils::UnicodeFractionsTest < ActiveSupport::TestCase
  def test_converts_common_unicode_fractions_to_ascii
    assert_equal "1/2 cup", RecipeUtils::UnicodeFractions.convert("½ cup")
    assert_equal "1/4 teaspoon", RecipeUtils::UnicodeFractions.convert("¼ teaspoon")
    assert_equal "3/4 pound", RecipeUtils::UnicodeFractions.convert("¾ pound")
  end

  def test_converts_multiple_unicode_fractions_in_same_string
    assert_equal "1/2 to 3/4 cup", RecipeUtils::UnicodeFractions.convert("½ to ¾ cup")
  end

  def test_converts_all_supported_unicode_fractions
    # Quarters
    assert_equal "1/4", RecipeUtils::UnicodeFractions.convert("¼")
    assert_equal "1/2", RecipeUtils::UnicodeFractions.convert("½")
    assert_equal "3/4", RecipeUtils::UnicodeFractions.convert("¾")

    # Thirds
    assert_equal "1/3", RecipeUtils::UnicodeFractions.convert("⅓")
    assert_equal "2/3", RecipeUtils::UnicodeFractions.convert("⅔")

    # Fifths
    assert_equal "1/5", RecipeUtils::UnicodeFractions.convert("⅕")
    assert_equal "2/5", RecipeUtils::UnicodeFractions.convert("⅖")
    assert_equal "3/5", RecipeUtils::UnicodeFractions.convert("⅗")
    assert_equal "4/5", RecipeUtils::UnicodeFractions.convert("⅘")

    # Sixths
    assert_equal "1/6", RecipeUtils::UnicodeFractions.convert("⅙")
    assert_equal "5/6", RecipeUtils::UnicodeFractions.convert("⅚")

    # Eighths
    assert_equal "1/8", RecipeUtils::UnicodeFractions.convert("⅛")
    assert_equal "3/8", RecipeUtils::UnicodeFractions.convert("⅜")
    assert_equal "5/8", RecipeUtils::UnicodeFractions.convert("⅝")
    assert_equal "7/8", RecipeUtils::UnicodeFractions.convert("⅞")

    # Sevenths, ninths, tenths
    assert_equal "1/7", RecipeUtils::UnicodeFractions.convert("⅐")
    assert_equal "1/9", RecipeUtils::UnicodeFractions.convert("⅑")
    assert_equal "1/10", RecipeUtils::UnicodeFractions.convert("⅒")
  end

  def test_handles_text_without_unicode_fractions
    assert_equal "1/2 cup sugar", RecipeUtils::UnicodeFractions.convert("1/2 cup sugar")
    assert_equal "2 cups flour", RecipeUtils::UnicodeFractions.convert("2 cups flour")
  end

  def test_handles_empty_string
    assert_equal "", RecipeUtils::UnicodeFractions.convert("")
  end

  def test_handles_nil
    assert_nil RecipeUtils::UnicodeFractions.convert(nil)
  end

  def test_detects_presence_of_unicode_fractions
    assert RecipeUtils::UnicodeFractions.contains_unicode_fraction?("½ cup")
    assert RecipeUtils::UnicodeFractions.contains_unicode_fraction?("¼ teaspoon")
    assert RecipeUtils::UnicodeFractions.contains_unicode_fraction?("use ⅓ cup sugar")
  end

  def test_detects_absence_of_unicode_fractions
    refute RecipeUtils::UnicodeFractions.contains_unicode_fraction?("1/2 cup")
    refute RecipeUtils::UnicodeFractions.contains_unicode_fraction?("2 cups flour")
    refute RecipeUtils::UnicodeFractions.contains_unicode_fraction?("")
  end

  def test_handles_nil_in_contains_unicode_fraction
    refute RecipeUtils::UnicodeFractions.contains_unicode_fraction?(nil)
  end

  def test_preserves_surrounding_text_when_converting
    assert_equal "Add 1/2 cup of sugar to the mixture",
                 RecipeUtils::UnicodeFractions.convert("Add ½ cup of sugar to the mixture")
  end

  def test_handles_mixed_numbers_with_unicode_fractions
    # Note: This would be "2½" which should convert to "2 1/2" ideally
    # But for now we just convert the fraction part
    assert_equal "21/2 cups", RecipeUtils::UnicodeFractions.convert("2½ cups")
  end
end
