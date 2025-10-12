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
      notes << part.strip
    end
  
    notes
  end
end
