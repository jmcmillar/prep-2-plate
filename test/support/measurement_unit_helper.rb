# Builds the measurement units the ingredient parser tests rely on, on top of
# the fixtures (ounce/oz, cup/cps, can, teaspoon, pound, tablespoon).
module MeasurementUnitHelper
  EXTRA_UNITS = [ "clove", "medium", "large", "pinch", "fluid ounce", "bottle", "package", "whole", "gram" ].freeze
  ALIASES = {
    "cup" => %w[c C],
    "tablespoon" => %w[tbsp T],
    "teaspoon" => %w[tsp t],
    "pound" => %w[lb lbs],
    "fluid ounce" => [ "fl oz" ],
    "gram" => %w[g]
  }.freeze

  # Returns units keyed by downcased name.
  def create_parser_units
    EXTRA_UNITS.each { |name| unit_named(name) }
    ALIASES.each do |unit_name, aliases|
      unit = unit_named(unit_name)
      aliases.each { |alias_name| MeasurementUnitAlias.find_or_create_by!(measurement_unit: unit, name: alias_name) }
    end
    MeasurementUnit.all.index_by { |unit| unit.name.downcase }
  end

  # Fixtures skip the downcase callback, so match names case-insensitively.
  def unit_named(name)
    MeasurementUnit.where("LOWER(name) = ?", name).first || MeasurementUnit.create!(name: name)
  end
end
