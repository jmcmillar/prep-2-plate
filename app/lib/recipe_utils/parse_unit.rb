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
  end

  def possible_unit_match
    @possible_match ||= grouped_by_measurement.map do |measurement_unit, aliases|
      next unless measurement_unit.name.in?(ingredient_words) || measurement_unit.name.pluralize.in?(ingredient_words) || !(ingredient_words & aliases.pluck(:name)).empty?
      measurement_unit
    end.compact
  end

  def ingredient_words
    @ingredient.gsub(/^[0-9_ .\/]*/, "").split.map(&:downcase)
  end

  def grouped_by_measurement
    @grouped_by_measurement ||= MeasurementUnitAlias.includes(:measurement_unit).group_by(&:measurement_unit)
  end
end
