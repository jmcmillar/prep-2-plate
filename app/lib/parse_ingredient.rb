class ParseIngredient
  def initialize(ingredient_string)
    @ingredient = ingredient_string
  end

  def to_h
    {
      quantity: @ingredient.scan(/^[0-9_ .\/]*/).flatten.first.strip,
      measurement_unit_id: unit_parser.id,
      ingredient_name: RecipeUtils::ParseIngredientName.new(@ingredient, exclude_from_name).to_s,
      ingredient_notes: RecipeUtils::ParseNotes.new(@ingredient).to_s
    }
  end

  private

  def unit_parser
    @unit_parser ||= RecipeUtils::ParseUnit.to_data(@ingredient)
  end

  def exclude_from_name
    excludes = []
    excludes << note_parser.to_a
    excludes << unit_parser.alias_names

    excludes.flatten
  end

  def note_parser
    RecipeUtils::ParseNotes.new(@ingredient)
  end

  def quantity?
    @ingredient.scan(/^[0-9_ .\/]*/).flatten.first.present?
  end
end
