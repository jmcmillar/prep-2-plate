# Scores a rule-based ParseIngredient result as :high or :low without calling
# any model. Only :low lines are worth sending to the AI fallback.
class RecipeUtils::IngredientConfidence
  Result = Struct.new(:level, :reasons) do
    def low?
      level == :low
    end
  end

  MAX_NAME_WORDS = 5

  # Lines that are intentionally unitless and quantity-free.
  UNMEASURED = /\A(?:[\p{L}\s-]*\b(?:salt|pepper|peppercorns?)|salt and (?:black )?pepper|(?:nonstick )?cooking spray|ice|water|oil for frying)\z/i

  # Seeded unit spellings that are also ordinary words in ingredient names.
  AMBIGUOUS_UNIT_WORDS = %w[
    whole large small medium in head heads leaf leaves slice slices piece pieces
    can cans box bag jar bottle container stalk stalks sprig sprigs dash t c g l
  ].to_set.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(raw_line, parsed, unit_lookup:)
    @raw_line = raw_line.to_s
    @parsed = parsed
    @unit_lookup = unit_lookup
  end

  def call
    reasons = checks.select { |_reason, failed| failed }.keys
    Result.new(reasons.empty? ? :high : :low, reasons)
  end

  private

  def checks
    {
      blank_name: name.blank?,
      digits_in_name: name.match?(%r{\d|/}),
      unit_word_in_name: unit_word_in_name?,
      long_name: name.split.length > MAX_NAME_WORDS,
      alternatives_in_name: name.match?(/\s(?:or)\s/),
      nothing_measured: nothing_measured?
    }
  end

  def name
    @parsed[:ingredient_name].to_s
  end

  def unit_word_in_name?
    name.split.any? do |word|
      !AMBIGUOUS_UNIT_WORDS.include?(word) && @unit_lookup.all_names.include?(word)
    end
  end

  def nothing_measured?
    @parsed[:quantity].blank? && @parsed[:measurement_unit_id].blank? && !name.match?(UNMEASURED)
  end
end
