# Builds the instruction text for AI ingredient parsing. The unit list and
# rules come first and stay identical between requests; only the numbered
# lines change.
class RecipeImports::AiIngredientPrompt
  def initialize(lines, unit_names:)
    @lines = lines
    @unit_names = unit_names
  end

  def to_s
    <<~PROMPT
      You convert recipe ingredient lines into structured data for a grocery shopping list.
      Return one entry per line, using that line's index as line_index.

      Field rules:
      - quantity: the amount as a whole number ("2"), fraction ("1/2"), mixed number ("1 1/2") or decimal ("0.5"). For a range like "2-3", use the lower number. Use "" when there is no amount.
      - unit: exactly one of the allowed units below, or "" when the amount is a count of the item itself ("3 eggs") or there is no unit.
      - name: the grocery item a shopper would buy, lowercase and singular ("egg", "yellow onion", "chicken thigh"). Leave out amounts, units, sizes in parentheses and preparation steps.
      - notes: everything else worth keeping for the cook, such as "finely chopped", "divided", "about 14 oz", or "or margarine". Use "" when there is nothing.
      - packaging_form and preparation_style: fill only when the line says so explicitly, otherwise "".

      Allowed units: #{@unit_names.join(', ')}

      Lines:
      #{numbered_lines}
    PROMPT
  end

  private

  def numbered_lines
    @lines.each_with_index.map { |line, index| "#{index}: #{line}" }.join("\n")
  end
end
