# In-memory index of measurement units and their aliases.
#
# Loads every unit and alias once (two queries), so a single instance can be
# shared across all ingredient lines of an import. Single-letter aliases are
# matched case-sensitively ("T" = tablespoon, "t" = teaspoon); everything else
# is case-insensitive. Periods are ignored ("oz." == "oz", "fl. oz." == "fl oz").
class RecipeUtils::UnitLookup
  MAX_UNIT_WORDS = 2
  Match = Struct.new(:unit, :word_count)

  def initialize(units = MeasurementUnit.includes(:measurement_unit_aliases).to_a)
    @index = build_index(units)
    @aliases_by_unit_id = build_aliases(units)
  end

  # Finds the longest unit at the start of +words+.
  # Returns a Match or nil.
  def match_prefix(words)
    MAX_UNIT_WORDS.downto(1) do |count|
      next if words.length < count

      unit = find(words.first(count).join(" "))
      return Match.new(unit, count) if unit
    end
    nil
  end

  def find(text)
    key = normalize(text)
    return nil if key.blank?

    @index[key] || (key.length > 1 ? @index[key.downcase] : nil)
  end

  def alias_names(unit)
    return [] unless unit

    @aliases_by_unit_id.fetch(unit.id, [])
  end

  # Every known unit spelling, downcased, for spotting unconsumed unit words.
  def all_names
    @all_names ||= @index.keys.map(&:downcase).to_set
  end

  private

  def normalize(text)
    text.to_s.delete(".").squish
  end

  def build_index(units)
    units.each_with_object({}) do |unit, index|
      spellings_for(unit).each { |spelling| add_spelling(index, spelling, unit) }
    end
  end

  def add_spelling(index, spelling, unit)
    key = normalize(spelling)
    return if key.blank?

    key = key.downcase if key.length > 1
    index[key] ||= unit
  end

  def spellings_for(unit)
    [ unit.name, unit.name.pluralize, *unit.measurement_unit_aliases.map(&:name) ]
  end

  def build_aliases(units)
    units.to_h { |unit| [ unit.id, spellings_for(unit).uniq ] }
  end
end
