# Parses one ingredient line ("1½ cups whole milk, warmed") into structured
# attributes. Works left to right: quantity, then the unit immediately after
# it, then the name up to the first comma. Parenthetical text, the comma tail,
# and serving phrases ("to taste") become notes.
#
# Pass a shared RecipeUtils::UnitLookup when parsing many lines to avoid
# reloading measurement units for each one.
class ParseIngredient
  NUMBER = %r{\d+\s+\d+/\d+|\d+/\d+|\d*\.\d+|\d+}
  QUANTITY = /\A(?<low>#{NUMBER})(?:\s*(?:-|–|—|to)\s*(?<high>#{NUMBER}))?(?=\s|\z|[^\d\/.])/
  ARTICLE_QUANTITY = /\A(?:an?)\s+/i
  TRAILING_NOTE = /\s+(?<note>plus .+|to taste|for (?:garnish|serving|dusting|greasing|topping)|as needed|if desired|optional)\s*\z/i
  LEADING_JUNK = /\A[\s*•\-–—]+/
  COMMA_ADJECTIVE = /\A(?:[\p{L}-]+less|bone-in|skin-on|unsalted|salted|ripe|pitted|peeled|seeded|lean|extra-lean)\z/i

  def initialize(ingredient_string, unit_lookup: nil)
    @raw = ingredient_string.to_s
    @unit_lookup = unit_lookup
  end

  def to_h
    {
      quantity: quantity,
      measurement_unit_id: unit&.id,
      ingredient_name: RecipeUtils::CanonicalName.call(descriptors.name),
      packaging_form: descriptors.packaging_form,
      preparation_style: descriptors.preparation_style,
      ingredient_notes: notes.join(", ")
    }
  end

  # The partial ingredient name being typed at the end of the line, after the
  # quantity and unit ("2 cups fl" -> "fl"). Nil once the name is finished and
  # the line has moved on to notes ("2 cups flour, sifted").
  def name_fragment
    fragment = after_unit.sub(/\A,\s*/, "").squish
    fragment unless fragment.empty? || fragment.include?(",")
  end

  private

  def normalized
    @normalized ||= RecipeUtils::UnicodeFractions.convert(RecipeUtils::CleanText.call(@raw)).sub(LEADING_JUNK, "")
  end

  def parentheticals
    @parentheticals ||= RecipeUtils::Parentheticals.new(normalized)
  end

  # Prices such as "($0.28)" (Budget Bytes) are not cooking notes.
  def parenthetical_notes
    parentheticals.groups.reject { |group| group.match?(/\A\$\s?[\d.,]+\z/) }
  end

  def without_parentheticals
    parentheticals.text
  end

  def quantity_match
    return @quantity_match if defined?(@quantity_match)

    @quantity_match = without_parentheticals.match(QUANTITY)
  end

  def quantity
    return quantity_match[:low].squish.sub(/\A\./, "0.") if quantity_match
    return "1" if article_unit_match

    ""
  end

  def range_note
    return nil unless quantity_match && quantity_match[:high]

    "#{quantity_match[:low].squish}-#{quantity_match[:high].squish}"
  end

  def after_quantity
    @after_quantity ||= text_after_quantity
  end

  def text_after_quantity
    return quantity_match.post_match.strip if quantity_match
    return without_parentheticals.sub(ARTICLE_QUANTITY, "") if article_unit_match

    without_parentheticals
  end

  def article_unit_match
    return @article_unit_match if defined?(@article_unit_match)

    words = without_parentheticals.sub(ARTICLE_QUANTITY, "").split
    @article_unit_match = without_parentheticals.match?(ARTICLE_QUANTITY) ? unit_lookup.match_prefix(words) : nil
  end

  def unit_match
    return @unit_match if defined?(@unit_match)

    @unit_match = unit_lookup.match_prefix(after_quantity.split.map { |word| word.delete(",") })
  end

  def unit
    unit_match&.unit
  end

  def after_unit
    words = after_quantity.split
    words = words.drop(unit_match.word_count) if unit_match
    words = words.drop(1) if words.first&.downcase == "of"
    words.join(" ")
  end

  # Splits at the first comma, except commas between leading adjectives
  # ("boneless, skinless chicken breasts" keeps one name).
  def head_and_tail
    @head_and_tail ||= begin
      parts = after_unit.sub(/\A,\s*/, "").split(/\s*,\s*/)
      head = parts.shift.to_s
      head = "#{head} #{parts.shift}" while parts.any? && head.split.all? { |word| word.match?(COMMA_ADJECTIVE) }
      [ head, parts.join(", ").presence ]
    end
  end

  def head_match
    @head_match ||= head_and_tail.first.to_s.match(TRAILING_NOTE)
  end

  def name_text
    name_and_alternative.first
  end

  # "baking soda / bi-carb" and "butter or margarine" keep the first item as
  # the name and move the alternative to notes.
  def name_and_alternative
    @name_and_alternative ||= begin
      head = head_and_tail.first.to_s
      head = head_match.pre_match if head_match
      name, alternative = head.split(%r{\s+(?:/|or)\s+}i, 2)
      [ name.to_s, alternative.presence && "or #{alternative}" ]
    end
  end

  def comma_note
    head_and_tail[1].presence&.sub(/[.;]\z/, "")
  end

  def base_notes
    [ *parenthetical_notes, range_note, name_and_alternative.last, head_match&.[](:note), comma_note ].compact_blank
  end

  def descriptors
    @descriptors ||= RecipeUtils::ParseDescriptors.call(name_text, notes: base_notes, unit: unit)
  end

  def notes
    (base_notes + descriptors.notes).uniq
  end

  def unit_lookup
    @unit_lookup ||= RecipeUtils::UnitLookup.new
  end
end
