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

    @ingredient.scan(/\(([^)]+)\)/) do |match|
      notes << match.first
    end

    @ingredient.split(/,\s*/).drop(1).each do |part|
      # Remove parenthetical content from comma-separated parts
      cleaned_part = part.gsub(/\([^)]*\)/, "").strip
      notes << cleaned_part unless cleaned_part.empty?
    end

    notes
  end
end
