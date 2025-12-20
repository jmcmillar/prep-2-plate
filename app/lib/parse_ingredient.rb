class ParseIngredient
  def initialize(ingredient_string)
    @ingredient = ingredient_string
    @normalized_ingredient = RecipeUtils::UnicodeFractions.convert(ingredient_string)
  end

  def to_h
    {
      quantity: extract_quantity,
      measurement_unit_id: unit_parser.id,
      ingredient_name: extract_base_name,
      packaging_form: extract_packaging_form,
      preparation_style: extract_preparation_style,
      ingredient_notes: RecipeUtils::ParseNotes.new(@normalized_ingredient).to_s
    }
  end

  private

  def extract_quantity
    # Handle formats like:
    # "4 (5 ounce)" -> "4"
    # "1 (10.5 ounce) can" -> "1"
    # "2 cups" -> "2"
    # "1/2 cup" -> "1/2"

    # First try to match quantity with optional parenthetical size
    # Pattern: number, optional space, optional parenthetical content
    match = @normalized_ingredient.match(/^(\d+(?:\s+\d+\/\d+|\.\d+|\/\d+)?)\s*(?:\([^)]+\))?\s*/)

    if match
      match[1].strip
    else
      ""
    end
  end

  def extract_packaging_form
    # First check for explicit packaging keywords (canned, frozen, dried, fresh)
    packaging_keywords.each do |keyword, _form|
      if @normalized_ingredient.downcase.match?(/\b#{keyword}\b/)
        return keyword
      end
    end

    # Then check for container indicators that imply packaging
    # This includes checking both in parentheses and in the main text
    # Examples: "1 (10.5 ounce) can" or "2 cans tomatoes"
    container_to_packaging.each do |container, packaging|
      if @normalized_ingredient.downcase.match?(/\b#{container}\b/)
        return packaging
      end
    end

    nil
  end

  def extract_preparation_style
    preparation_keywords.each do |keyword, _style|
      if @normalized_ingredient.downcase.match?(/\b#{keyword}\b/)
        return keyword
      end
    end
    nil
  end

  def extract_base_name
    RecipeUtils::ParseIngredientName.new(@normalized_ingredient, exclude_from_name).to_s
  end

  def packaging_keywords
    @packaging_keywords ||= Ingredient::PACKAGING_FORMS.transform_keys(&:to_s)
  end

  def preparation_keywords
    @preparation_keywords ||= Ingredient::PREPARATION_STYLES.transform_keys(&:to_s)
  end

  def container_to_packaging
    {
      'can' => 'canned',
      'cans' => 'canned',
      'jar' => 'canned',
      'jars' => 'canned',
      'bottle' => 'canned',
      'bottles' => 'canned',
      'package' => 'frozen',
      'packages' => 'frozen',
      'box' => 'dried',
      'boxes' => 'dried',
      'bag' => 'dried',
      'bags' => 'dried'
    }
  end

  def unit_parser
    @unit_parser ||= RecipeUtils::ParseUnit.to_data(@normalized_ingredient)
  end

  def exclude_from_name
    excludes = []
    excludes << note_parser.to_a
    excludes << unit_parser.alias_names

    # Only exclude the detected packaging/preparation, not all of them
    excludes << extract_packaging_form if extract_packaging_form.present?
    excludes << extract_preparation_style if extract_preparation_style.present?

    # Exclude container words that indicate packaging
    excludes << container_to_packaging.keys

    excludes.flatten
  end

  def note_parser
    RecipeUtils::ParseNotes.new(@normalized_ingredient)
  end

  def quantity?
    @normalized_ingredient.scan(/^[0-9_ .\/]*/).flatten.first.present?
  end
end
