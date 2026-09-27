# Parses ingredient lines the rule-based parser was unsure about by sending
# them to Claude in one request per recipe. Results are validated against
# known units and Ingredient enums, then cached by line text so the same line
# is never paid for twice. Any line that fails validation is simply left out,
# so callers keep their rule-based result for it.
#
# Lines come from scraped pages, so a line can carry instructions aimed at the
# model. Every returned name must be made of words from its own source line,
# which stops one line from steering another line's result into the shared
# cache.
#
# Returns a Hash of { raw_line => ParseIngredient-style hash }.
class RecipeImports::AiParseIngredients
  include Service

  MODEL = "claude-haiku-4-5"
  MAX_TOKENS = 4096
  CACHE_VERSION = "v1"
  CACHE_TTL = 90.days
  QUANTITY_FORMAT = %r{\A(?:\d+ \d+/\d+|\d+/\d+|\d+(?:\.\d+)?)?\z}

  def self.enabled?
    ENV["ANTHROPIC_API_KEY"].present? &&
      ActiveModel::Type::Boolean.new.cast(ENV.fetch("RECIPE_IMPORT_AI_FALLBACK", false))
  end

  def initialize(lines, unit_lookup:, cache: Rails.cache, client: Clients::ClaudeApi)
    @lines = lines.uniq
    @unit_lookup = unit_lookup
    @cache = cache
    @client = client
  end

  def call
    return {} if @lines.empty?

    cached = cached_results
    uncached = @lines - cached.keys
    cached.merge(fetch_and_cache(uncached))
  end

  private

  def cached_results
    @lines.each_with_object({}) do |line, results|
      stored = @cache.read(cache_key(line))
      parsed = stored && to_parsed_hash(stored, line)
      results[line] = parsed if parsed
    end
  end

  def fetch_and_cache(lines)
    return {} if lines.empty?

    items = request_items(lines)
    items.each_with_object({}) do |item, results|
      line = lines[item["line_index"].to_i]
      parsed = line && to_parsed_hash(item, line)
      next unless parsed

      @cache.write(cache_key(line), item, expires_in: CACHE_TTL)
      results[line] = parsed
    end
  end

  def request_items(lines)
    result = @client.call(prompt(lines), model: MODEL, max_tokens: MAX_TOKENS, output_schema: RecipeImports::AiIngredientSchema.schema)
    return log_failure(result.error_message) unless result.success?

    JSON.parse(result.data).fetch("ingredients", [])
  rescue JSON::ParserError, TypeError => e
    log_failure(e.message)
  end

  def log_failure(message)
    Rails.logger.warn("INGREDIENT_PARSE: AI fallback failed: #{message}")
    []
  end

  # Returns nil when the item fails validation.
  def to_parsed_hash(item, line)
    name = RecipeUtils::CanonicalName.call(item["name"])
    unit = @unit_lookup.find(item["unit"].to_s)
    return nil unless valid_item?(item, name, unit) && grounded?(name, line)

    {
      quantity: item["quantity"].to_s,
      measurement_unit_id: unit&.id,
      ingredient_name: name,
      packaging_form: item["packaging_form"].presence,
      preparation_style: item["preparation_style"].presence,
      ingredient_notes: item["notes"].to_s.strip
    }
  end

  def valid_item?(item, name, unit)
    name.present? && !name.match?(/\d/) &&
      item["quantity"].to_s.match?(QUANTITY_FORMAT) &&
      (item["unit"].blank? || unit) &&
      allowed?(item["packaging_form"], Ingredient::PACKAGING_FORMS) &&
      allowed?(item["preparation_style"], Ingredient::PREPARATION_STYLES)
  end

  def grounded?(name, line)
    line_words = RecipeUtils::CanonicalName.call(line).split
    known = line_words.to_set | line_words.map { |word| RecipeUtils::CanonicalName.call(word) }
    name.split.all? { |word| known.include?(word) }
  end

  def allowed?(value, enum)
    value.blank? || enum.key?(value.to_sym)
  end

  def cache_key(line)
    "recipe_imports/ai_ingredient/#{CACHE_VERSION}/#{Digest::SHA256.hexdigest(line.squish)}"
  end

  def prompt(lines)
    RecipeImports::AiIngredientPrompt.new(lines, unit_names: unit_names).to_s
  end

  def unit_names
    @unit_names ||= MeasurementUnit.order(:name).pluck(:name)
  end
end
