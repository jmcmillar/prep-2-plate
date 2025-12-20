class RecipeUtils::ParseNotes
  def initialize(ingredient)
    @ingredient = ingredient
  end

  def to_s
    ingredient_notes.join(", ")
  end

  def to_a
    ingredient_notes
  end

  private

  def ingredient_notes
    notes = []

    # Extract ALL parenthetical content as notes
    @ingredient.scan(/\(([^)]+)\)/) do |match|
      notes << match.first
    end

    # For comma-separated parts, only treat as notes if they match certain patterns
    # Don't treat all comma-separated text as notes (e.g., "skinless, boneless" are descriptors)
    @ingredient.split(/,\s*/).drop(1).each do |part|
      # Remove parenthetical content from comma-separated parts
      cleaned_part = part.gsub(/\([^)]*\)/, "").strip

      # Only add as note if it looks like a note pattern:
      # - Contains preparation instructions ("finely chopped", "cut into pieces")
      # - Contains references ("optional", "or substitute", "to taste")
      # - Is a standalone descriptor that's not part of the ingredient name
      note_patterns = [
        /\b(optional|to taste|or substitute|or|divided|plus more)\b/i,
        /\b(finely|coarsely|thinly|thickly|roughly)\s+(chopped|sliced|diced|minced|cut)/i,
        /\b(cut into|sliced into|chopped into)\b/i
      ]

      is_note = note_patterns.any? { |pattern| cleaned_part.match?(pattern) }
      notes << cleaned_part if is_note && !cleaned_part.empty?
    end

    notes
  end
end
