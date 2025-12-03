class ParseIngredient
  def initialize(ingredient_string)
    @ingredient = ingredient_string
    @normalized_ingredient = RecipeUtils::UnicodeFractions.convert(ingredient_string)
  end

  def to_h
    {
      quantity: @normalized_ingredient.scan(/^[0-9_ .\/]*/).flatten.first&.strip || "",
      measurement_unit_id: unit_parser.id,
      ingredient_name: RecipeUtils::ParseIngredientName.new(@normalized_ingredient, exclude_from_name).to_s,
      ingredient_notes: RecipeUtils::ParseNotes.new(@normalized_ingredient).to_s
    }
  end

  private

  def unit_parser
    @unit_parser ||= RecipeUtils::ParseUnit.to_data(@normalized_ingredient)
  end

  def exclude_from_name
    excludes = []
    excludes << note_parser.to_a
    excludes << unit_parser.alias_names

    excludes.flatten
  end

  def note_parser
    RecipeUtils::ParseNotes.new(@normalized_ingredient)
  end

  def quantity?
    @normalized_ingredient.scan(/^[0-9_ .\/]*/).flatten.first.present?
  end
end
