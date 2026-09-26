# Pulls packaging form ("canned") and preparation style ("diced") off an
# ingredient name. Only leading adjectives are taken from the name, so
# "whole milk" or "ground beef" stay intact; otherwise the notes and the
# container unit ("1 can ...") are consulted.
class RecipeUtils::ParseDescriptors
  Result = Struct.new(:name, :packaging_form, :preparation_style, :notes, keyword_init: true)

  COMPOUND_NAMES = [
    "whole milk", "whole wheat", "whole grain", "whole-wheat", "whole-grain",
    "ground beef", "ground turkey", "ground pork", "ground chicken",
    "ground lamb", "ground veal", "ground meat", "ground sausage",
    "crushed red pepper", "fresh mozzarella"
  ].freeze

  ADVERBS = %w[finely coarsely roughly thinly thickly freshly lightly].to_set.freeze

  # States written after the name without a comma ("200g butter softened").
  TRAILING_STATES = %w[
    softened melted beaten sifted drained rinsed divided peeled halved
    quartered trimmed toasted warmed cooled chopped diced sliced minced
    crushed shredded grated cubed cooked
  ].to_set.freeze

  CONTAINER_PACKAGING = {
    "can" => "canned",
    "tin" => "canned",
    "jar" => "canned",
    "bottle" => "bottled"
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(name, notes: [], unit: nil)
    @words = name.to_s.split
    @notes_text = Array(notes).join(" ").downcase
    @unit_name = unit&.name.to_s.downcase
    @packaging = nil
    @preparation = nil
    @extra_notes = []
  end

  def call
    remaining = strip_leading_descriptors
    Result.new(
      name: remaining.join(" "),
      packaging_form: @packaging || packaging_from_notes || CONTAINER_PACKAGING[@unit_name],
      preparation_style: @preparation || preparation_from_notes,
      notes: @extra_notes
    )
  end

  private

  def strip_leading_descriptors
    words = @words.dup
    words = consume_descriptor(words) while descriptor_ahead?(words)
    strip_trailing_states(words)
  end

  def strip_trailing_states(words)
    trailing = []
    trailing.unshift(words.pop.downcase) while words.length > 1 && TRAILING_STATES.include?(words.last.downcase)
    return words if trailing.empty?

    @preparation ||= trailing.find { |word| preparation_keyword?(word) }
    @extra_notes << trailing.join(" ")
    words
  end

  def descriptor_ahead?(words)
    return false if words.length < 2 || compound_name?(words)

    lead = words.first.downcase
    adverb_before_prep?(words) ||
      (preparation_keyword?(lead) && @preparation.nil?) ||
      (packaging_keyword?(lead) && @packaging.nil?)
  end

  def consume_descriptor(words)
    return consume_adverb_phrase(words) if adverb_before_prep?(words)

    lead = words.first.downcase
    preparation_keyword?(lead) && @preparation.nil? ? @preparation = lead : @packaging = lead
    words.drop(1)
  end

  def consume_adverb_phrase(words)
    @preparation = words[1].downcase
    @extra_notes << words.first(2).join(" ").downcase
    words.drop(2)
  end

  def adverb_before_prep?(words)
    words.length > 2 && @preparation.nil? &&
      ADVERBS.include?(words.first.downcase) && preparation_keyword?(words[1].downcase)
  end

  def compound_name?(words)
    text = words.join(" ").downcase
    COMPOUND_NAMES.any? { |compound| text == compound || text.start_with?("#{compound} ") }
  end

  def packaging_from_notes
    first_keyword_in_notes(packaging_keywords)
  end

  def preparation_from_notes
    first_keyword_in_notes(preparation_keywords)
  end

  def first_keyword_in_notes(keywords)
    return nil if @notes_text.blank?

    keywords.filter_map { |keyword| [ @notes_text =~ /\b#{keyword}\b/, keyword ] }
            .select(&:first)
            .min_by(&:first)
            &.last
  end

  def preparation_keyword?(word)
    preparation_keywords.include?(word)
  end

  def packaging_keyword?(word)
    packaging_keywords.include?(word)
  end

  def preparation_keywords
    @preparation_keywords ||= Ingredient::PREPARATION_STYLES.keys.map(&:to_s)
  end

  def packaging_keywords
    @packaging_keywords ||= Ingredient::PACKAGING_FORMS.keys.map(&:to_s)
  end
end
