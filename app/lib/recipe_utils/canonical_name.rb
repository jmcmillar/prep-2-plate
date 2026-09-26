# Produces a stable ingredient name so "Eggs" and "egg" map to one Ingredient.
# Keeps hyphens and apostrophes, drops other punctuation, downcases, and
# singularizes the last word with food-safe rules (ActiveSupport's inflector
# turns "olives" into "olife" and "molasses" into "molass").
class RecipeUtils::CanonicalName
  UNCOUNTABLE = %w[
    asparagus brussels citrus couscous greens grits hibiscus hummus
    molasses oats swiss series
  ].to_set.freeze

  IRREGULAR = {
    "leaves" => "leaf",
    "halves" => "half",
    "loaves" => "loaf",
    "cookies" => "cookie",
    "brownies" => "brownie",
    "veggies" => "veggie",
    "pies" => "pie",
    "smoothies" => "smoothie"
  }.freeze

  def self.call(name)
    new(name).to_s
  end

  def initialize(name)
    @name = name.to_s
  end

  def to_s
    words = cleaned.split
    return "" if words.empty?

    words[-1] = singularize(words.last)
    words.join(" ")
  end

  private

  def cleaned
    @name.downcase
         .gsub(/[’‘]/, "'")
         .gsub(/[^\p{L}\p{N}\s'-]/, " ")
         .gsub(/(?<![\p{L}\p{N}])[-']+|[-']+(?![\p{L}\p{N}])/, " ")
         .squish
  end

  def singularize(word)
    return word if keep_as_is?(word)
    return IRREGULAR[word] if IRREGULAR.key?(word)

    case word
    when /ies\z/ then word.sub(/ies\z/, "y")
    when /oes\z/, /(ch|sh|x|ss)es\z/ then word.sub(/es\z/, "")
    else word.sub(/s\z/, "")
    end
  end

  def keep_as_is?(word)
    UNCOUNTABLE.include?(word) || word.length <= 3 || word.match?(/(ss|us|is)\z/) || !word.end_with?("s")
  end
end
