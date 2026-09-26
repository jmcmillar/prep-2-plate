# Parses every ingredient line of an import: rule-based first, then the AI
# fallback for lines the confidence gate marks :low (when enabled).
#
# Returns an Array of ParseIngredient-style hashes, in line order.
class RecipeImports::ParseIngredientLines
  include Service

  def initialize(lines, unit_lookup: RecipeUtils::UnitLookup.new, ai_parser: RecipeImports::AiParseIngredients,
                 ai_enabled: RecipeImports::AiParseIngredients.enabled?)
    @lines = Array(lines).map(&:to_s).reject(&:blank?)
    @unit_lookup = unit_lookup
    @ai_parser = ai_parser
    @ai_enabled = ai_enabled
  end

  def call
    ai_results = @ai_enabled ? @ai_parser.call(low_confidence_lines, unit_lookup: @unit_lookup) : {}
    log_summary(ai_results)
    @lines.map { |line| ai_results[line] || rule_results[line] }
  end

  private

  def rule_results
    @rule_results ||= @lines.to_h { |line| [ line, ParseIngredient.new(line, unit_lookup: @unit_lookup).to_h ] }
  end

  def confidence
    @confidence ||= @lines.to_h do |line|
      [ line, RecipeUtils::IngredientConfidence.call(line, rule_results[line], unit_lookup: @unit_lookup) ]
    end
  end

  def low_confidence_lines
    @lines.select { |line| confidence[line].low? }.uniq
  end

  def log_summary(ai_results)
    low = low_confidence_lines
    Rails.logger.info(
      "INGREDIENT_PARSE: lines=#{@lines.size} low_confidence=#{low.size} " \
      "ai_resolved=#{ai_results.size} ai_enabled=#{@ai_enabled} " \
      "reasons=#{low.flat_map { |line| confidence[line].reasons }.tally}"
    )
  end
end
