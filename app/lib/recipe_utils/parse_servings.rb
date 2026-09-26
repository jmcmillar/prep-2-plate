# Extracts a serving count from schema.org recipeYield, which may be an
# integer, a string ("Serves 4-6", "Makes 12 cookies"), or an array of both.
class RecipeUtils::ParseServings
  def self.call(recipe_yield)
    new(recipe_yield).to_i
  end

  def initialize(recipe_yield)
    @recipe_yield = recipe_yield
  end

  # Returns the first positive integer found, or nil.
  def to_i
    Array(@recipe_yield).each do |value|
      servings = value.is_a?(Numeric) ? value.to_i : value.to_s[/\d+/]&.to_i
      return servings if servings&.positive?
    end
    nil
  end
end
