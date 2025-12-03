require "test_helper"

class RecipeUtils::ParseIngredientNameTest < ActiveSupport::TestCase
  def test_strips_numbers_from_beginning_of_ingredient
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_strips_fractions_from_beginning_of_ingredient
    parser = RecipeUtils::ParseIngredientName.new("1/2 cup sugar")
    result = parser.to_s

    assert_equal "cup sugar", result
  end

  def test_strips_decimals_from_beginning_of_ingredient
    parser = RecipeUtils::ParseIngredientName.new("2.5 tablespoons olive oil")
    result = parser.to_s

    assert_equal "tablespoons olive oil", result
  end

  def test_strips_mixed_numbers_and_special_characters_from_beginning
    parser = RecipeUtils::ParseIngredientName.new("1 1/2 cups all-purpose flour")
    result = parser.to_s

    assert_equal "cups allpurpose flour", result
  end

  def test_removes_parenthetical_information
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour (sifted)")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_removes_multiple_parenthetical_sections
    parser = RecipeUtils::ParseIngredientName.new("1 cup sugar (white) or (brown)")
    result = parser.to_s

    assert_equal "cup sugar or", result
  end

  def test_removes_special_characters_but_keeps_letters_and_spaces
    parser = RecipeUtils::ParseIngredientName.new("2 cups all-purpose flour, sifted")
    result = parser.to_s

    assert_equal "cups allpurpose flour sifted", result
  end

  def test_handles_ingredient_with_no_numbers_or_special_characters
    parser = RecipeUtils::ParseIngredientName.new("salt to taste")
    result = parser.to_s

    assert_equal "salt to taste", result
  end

  def test_strips_excluded_substrings
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil leaves", ["fresh", "leaves"])
    result = parser.to_s

    assert_equal "cups basil", result
  end

  def test_strips_multiple_excluded_substrings
    excludes = ["chopped", "fresh", "organic"]
    parser = RecipeUtils::ParseIngredientName.new("1 cup fresh organic tomatoes chopped", excludes)
    result = parser.to_s

    assert_equal "cup tomatoes", result
  end

  def test_handles_excluded_substrings_that_dont_exist_in_ingredient
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour", ["fresh", "chopped"])
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_strips_excluded_substrings_case_insensitively
    parser = RecipeUtils::ParseIngredientName.new("2 cups Fresh basil", ["fresh"])
    result = parser.to_s

    # Should strip "Fresh" (capital F) when looking for "fresh" (lowercase f) because matching is case-insensitive
    assert_equal "cups basil", result
  end

  def test_handles_empty_ingredient_string
    parser = RecipeUtils::ParseIngredientName.new("")
    result = parser.to_s

    assert_equal "", result
  end

  def test_handles_ingredient_with_only_numbers_and_spaces
    parser = RecipeUtils::ParseIngredientName.new("2 1/2   ")
    result = parser.to_s

    assert_equal "", result
  end

  def test_trims_whitespace_from_result
    parser = RecipeUtils::ParseIngredientName.new("  2 cups flour  ")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_handles_complex_ingredient_with_all_transformations
    excludes = ["fresh", "chopped", "finely"]
    ingredient = "2 1/4 cups fresh basil leaves, finely chopped (organic)"
    parser = RecipeUtils::ParseIngredientName.new(ingredient, excludes)
    result = parser.to_s

    assert_equal "cups basil leaves", result
  end

  def test_strip_numbers_and_special_characters_method_works_independently
    parser = RecipeUtils::ParseIngredientName.new("test")
    result = parser.strip_numbers_and_special_characters("2.5 cups all-purpose flour (sifted)")

    assert_equal "cups allpurpose flour", result
  end

  def test_ingredient_stripped_of_substrings_method_works_independently
    parser = RecipeUtils::ParseIngredientName.new("test", ["fresh", "organic"])
    result = parser.ingredient_stripped_of_substrings("fresh organic basil leaves")

    assert_equal "basil leaves", result
  end

  def test_handles_ingredients_with_underscores_in_numbers
    parser = RecipeUtils::ParseIngredientName.new("1_000 grams flour")
    result = parser.to_s

    assert_equal "grams flour", result
  end

  def test_handles_ingredients_with_periods_in_numbers
    parser = RecipeUtils::ParseIngredientName.new("1.000 cups water")
    result = parser.to_s

    assert_equal "cups water", result
  end

  def test_preserves_words_that_contain_excluded_substrings
    parser = RecipeUtils::ParseIngredientName.new("2 cups freshly ground pepper", ["fresh"])
    result = parser.to_s

    # Should not strip "fresh" from "freshly" because word boundaries are used
    assert_equal "cups freshly ground pepper", result
  end

  def test_handles_unicode_characters_in_ingredient_names
    parser = RecipeUtils::ParseIngredientName.new("2 cups café au lait")
    result = parser.to_s

    assert_equal "cups café au lait", result
  end

  def test_handles_ingredients_with_mixed_case
    parser = RecipeUtils::ParseIngredientName.new("2 Cups ALL-PURPOSE Flour")
    result = parser.to_s

    assert_equal "Cups ALLPURPOSE Flour", result
  end

  def test_strips_leading_spaces_and_dots_from_numbers_section
    parser = RecipeUtils::ParseIngredientName.new("  . 2 cups flour")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_handles_parentheses_with_spaces_inside
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour ( well sifted )")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  def test_handles_nested_or_malformed_parentheses
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour (sifted) extra text")
    result = parser.to_s

    assert_equal "cups flour extra text", result
  end

  def test_excludes_substrings_are_applied_in_order
    excludes = ["fresh basil", "basil"]  # More specific first
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil leaves", excludes)
    result = parser.to_s

    assert_equal "cups leaves", result
  end

  def test_handles_empty_excludes_array
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil", [])
    result = parser.to_s

    assert_equal "cups fresh basil", result
  end

  def test_strips_unicode_fraction_one_half_from_beginning
    parser = RecipeUtils::ParseIngredientName.new("½ cup sugar")
    result = parser.to_s

    assert_equal "cup sugar", result
    refute_includes result, "½"
  end

  def test_strips_unicode_fraction_one_quarter_from_beginning
    parser = RecipeUtils::ParseIngredientName.new("¼ teaspoon salt")
    result = parser.to_s

    assert_equal "teaspoon salt", result
    refute_includes result, "¼"
  end

  def test_strips_unicode_fraction_three_quarters_from_beginning
    parser = RecipeUtils::ParseIngredientName.new("¾ cup milk")
    result = parser.to_s

    assert_equal "cup milk", result
    refute_includes result, "¾"
  end

  def test_strips_unicode_fraction_one_third_from_beginning
    parser = RecipeUtils::ParseIngredientName.new("⅓ cup olive oil")
    result = parser.to_s

    assert_equal "cup olive oil", result
    refute_includes result, "⅓"
  end

  def test_strips_mixed_number_with_unicode_fraction
    parser = RecipeUtils::ParseIngredientName.new("2½ cups flour")
    result = parser.to_s

    assert_equal "cups flour", result
    refute_includes result, "½"
  end

  def test_handles_unicode_fractions_with_excludes
    parser = RecipeUtils::ParseIngredientName.new("½ cup fresh basil", ["fresh"])
    result = parser.to_s

    assert_equal "cup basil", result
    refute_includes result, "½"
    refute_includes result, "fresh"
  end
end
