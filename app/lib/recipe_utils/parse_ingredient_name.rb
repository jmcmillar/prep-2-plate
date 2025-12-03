class RecipeUtils::ParseIngredientName
  def initialize(ingredient, excludes_substrings = [])
    @ingredient = ingredient
    @excludes_substrings = excludes_substrings
  end

  def to_s
    # First normalize Unicode fractions to ASCII
    normalized = RecipeUtils::UnicodeFractions.convert(@ingredient)

    # Then strip numbers and get the core text
    stripped_chars = strip_numbers_and_special_characters(normalized)

    # Then remove excluded words
    result = ingredient_stripped_of_substrings(stripped_chars)

    # Final cleanup of multiple spaces and trim
    result.gsub(/\s+/, " ").strip
  end

  def strip_numbers_and_special_characters(name)
    name.gsub(/^[0-9_ .\/]*/, "")
        .gsub(/\([^)]*\)/, "")
        .gsub(/[^\p{L}\p{N}\s]/, "")  # Use Unicode character classes for letters and numbers
        .gsub(/\s+/, " ")  # Collapse multiple spaces into single space
        .strip
  end

  def ingredient_stripped_of_substrings(name)
    return name if @excludes_substrings.blank?
    
    @excludes_substrings.flatten.compact.reject(&:blank?).each do |substring|
      # Remove the substring with word boundaries (case insensitive)
      # Replace with single space to avoid joining words
      name = name.gsub(/\b#{Regexp.escape(substring.to_s.strip)}\b/i, ' ')
    end
    
    # Clean up multiple spaces and trim
    name.gsub(/\s+/, ' ').strip
  end

end
