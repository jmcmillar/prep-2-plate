class RecipeUtils::ParseUnit
  Data = Struct.new(:id, :alias_names)
  
  def initialize(ingredient)
    @ingredient = ingredient
  end

  def self.to_data(...)
    new(...).to_data
  end

  def to_data
    return Data[nil, []] unless possible_unit_match.present?
    Data.new(possible_unit_match.first.id, alias_names)
  end

  def alias_names
    return [] unless possible_unit_match.present?
    aliases = possible_unit_match.first.measurement_unit_aliases.pluck(:name)
    aliases << possible_unit_match.first.name
    aliases << possible_unit_match.first.name.pluralize
    aliases.uniq
  end

  def possible_unit_match
    @possible_match ||= MeasurementUnit.includes(:measurement_unit_aliases).map do |measurement_unit|
      # Check if unit name (singular or plural) is in ingredient words
      unit_names = [measurement_unit.name.downcase, measurement_unit.name.pluralize.downcase]
      unit_match = (unit_names & ingredient_words).any?
      
      # Check if any alias names match ingredient words
      alias_names = measurement_unit.measurement_unit_aliases.pluck(:name).map(&:downcase)
      alias_match = (alias_names & ingredient_words).any?
      
      # Return the measurement unit if either condition is true
      measurement_unit if unit_match || alias_match
    end.compact
  end

  def ingredient_words
    @ingredient_words ||= @ingredient
      .gsub(/^[0-9_ .\/]*/, "")  # Strip leading numbers and fractions
      .gsub(/\([^)]*\)/, "")     # Remove parenthetical content
      .split                      # Split into words
      .map { |word| word.gsub(/[^\p{L}\p{N}]/, "").downcase }  # Remove punctuation and downcase
      .reject(&:blank?)           # Remove empty strings
  end

  def grouped_by_measurement
    @grouped_by_measurement ||= MeasurementUnitAlias.includes(:measurement_unit).group_by(&:measurement_unit)
  end
end
