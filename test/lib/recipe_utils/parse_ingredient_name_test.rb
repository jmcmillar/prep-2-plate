require "test_helper"

class RecipeUtils::ParseIngredientNameTest < ActiveSupport::TestCase
  test "strips numbers from beginning of ingredient" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "strips fractions from beginning of ingredient" do
    parser = RecipeUtils::ParseIngredientName.new("1/2 cup sugar")
    result = parser.to_s

    assert_equal "cup sugar", result
  end

  test "strips decimals from beginning of ingredient" do
    parser = RecipeUtils::ParseIngredientName.new("2.5 tablespoons olive oil")
    result = parser.to_s

    assert_equal "tablespoons olive oil", result
  end

  test "strips mixed numbers and special characters from beginning" do
    parser = RecipeUtils::ParseIngredientName.new("1 1/2 cups all-purpose flour")
    result = parser.to_s

    assert_equal "cups allpurpose flour", result
  end

  test "removes parenthetical information" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour (sifted)")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "removes multiple parenthetical sections" do
    parser = RecipeUtils::ParseIngredientName.new("1 cup sugar (white) or (brown)")
    result = parser.to_s

    assert_equal "cup sugar or", result
  end

  test "removes special characters but keeps letters and spaces" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups all-purpose flour, sifted")
    result = parser.to_s

    assert_equal "cups allpurpose flour sifted", result
  end

  test "handles ingredient with no numbers or special characters" do
    parser = RecipeUtils::ParseIngredientName.new("salt to taste")
    result = parser.to_s

    assert_equal "salt to taste", result
  end

  test "strips excluded substrings" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil leaves", ["fresh", "leaves"])
    result = parser.to_s

    assert_equal "cups basil", result
  end

  test "strips multiple excluded substrings" do
    excludes = ["chopped", "fresh", "organic"]
    parser = RecipeUtils::ParseIngredientName.new("1 cup fresh organic tomatoes chopped", excludes)
    result = parser.to_s

    assert_equal "cup tomatoes", result
  end

  test "handles excluded substrings that don't exist in ingredient" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour", ["fresh", "chopped"])
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "strips excluded substrings case sensitively" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups Fresh basil", ["fresh"])
    result = parser.to_s

    # Should not strip "Fresh" (capital F) when looking for "fresh" (lowercase f)
    assert_equal "cups Fresh basil", result
  end

  test "handles empty ingredient string" do
    parser = RecipeUtils::ParseIngredientName.new("")
    result = parser.to_s

    assert_equal "", result
  end

  test "handles ingredient with only numbers and spaces" do
    parser = RecipeUtils::ParseIngredientName.new("2 1/2   ")
    result = parser.to_s

    assert_equal "", result
  end

  test "trims whitespace from result" do
    parser = RecipeUtils::ParseIngredientName.new("  2 cups flour  ")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "handles complex ingredient with all transformations" do
    excludes = ["fresh", "chopped", "finely"]
    ingredient = "2 1/4 cups fresh basil leaves, finely chopped (organic)"
    parser = RecipeUtils::ParseIngredientName.new(ingredient, excludes)
    result = parser.to_s

    assert_equal "cups basil leaves", result
  end

  test "strip_numbers_and_special_characters method works independently" do
    parser = RecipeUtils::ParseIngredientName.new("test")
    result = parser.strip_numbers_and_special_characters("2.5 cups all-purpose flour (sifted)")

    assert_equal "cups allpurpose flour", result
  end

  test "ingredient_stripped_of_substrings method works independently" do
    parser = RecipeUtils::ParseIngredientName.new("test", ["fresh", "organic"])
    result = parser.ingredient_stripped_of_substrings("fresh organic basil leaves")

    assert_equal "basil leaves", result
  end

  test "handles ingredients with underscores in numbers" do
    parser = RecipeUtils::ParseIngredientName.new("1_000 grams flour")
    result = parser.to_s

    assert_equal "grams flour", result
  end

  test "handles ingredients with periods in numbers" do
    parser = RecipeUtils::ParseIngredientName.new("1.000 cups water")
    result = parser.to_s

    assert_equal "cups water", result
  end

  test "preserves words that contain excluded substrings" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups freshly ground pepper", ["fresh"])
    result = parser.to_s

    # Should not strip "fresh" from "freshly"
    assert_equal "cups ly ground pepper", result
  end

  test "handles unicode characters in ingredient names" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups café au lait")
    result = parser.to_s

    assert_equal "cups café au lait", result
  end

  test "handles ingredients with mixed case" do
    parser = RecipeUtils::ParseIngredientName.new("2 Cups ALL-PURPOSE Flour")
    result = parser.to_s

    assert_equal "Cups ALLPURPOSE Flour", result
  end

  test "strips leading spaces and dots from numbers section" do
    parser = RecipeUtils::ParseIngredientName.new("  . 2 cups flour")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "handles parentheses with spaces inside" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour ( well sifted )")
    result = parser.to_s

    assert_equal "cups flour", result
  end

  test "handles nested or malformed parentheses" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups flour (sifted) extra text")
    result = parser.to_s

    assert_equal "cups flour extra text", result
  end

  test "excludes substrings are applied in order" do
    excludes = ["fresh basil", "basil"]  # More specific first
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil leaves", excludes)
    result = parser.to_s

    assert_equal "cups leaves", result
  end

  test "handles empty excludes array" do
    parser = RecipeUtils::ParseIngredientName.new("2 cups fresh basil", [])
    result = parser.to_s

    assert_equal "cups fresh basil", result
  end
end
