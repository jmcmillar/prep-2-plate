class RecipeUtils::ParseIngredientName
  def initialize(ingredient, excludes_substrings = [])
    @ingredient = ingredient
    @excludes_substrings = excludes_substrings
  end

  def to_s
    stripped_chars = strip_numbers_and_special_characters(@ingredient)
    ingredient_stripped_of_substrings(stripped_chars)
  end

  def strip_numbers_and_special_characters(name)
    name.gsub(/^[0-9_ .\/]*/, "").gsub(/\([^)]*\)/, "").gsub(/[^\w\s]/, "").strip
  end

  def ingredient_stripped_of_substrings(name)
    @excludes_substrings.each { |substring|
      name = name.gsub(substring, "")
    }
    name.strip
  end

end
