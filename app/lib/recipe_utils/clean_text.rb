# Normalizes text scraped from recipe pages: decodes HTML entities, strips
# tags and list-bullet glyphs, and collapses whitespace.
class RecipeUtils::CleanText
  BULLET_GLYPHS = /[▢□☐•▪◦●]/

  def self.call(text)
    new(text).to_s
  end

  def initialize(text)
    @text = text
  end

  def to_s
    return @text unless @text.is_a?(String)

    decoded = Nokogiri::HTML.fragment(@text).text
    decoded.gsub(BULLET_GLYPHS, " ")
           .tr(" ", " ")
           .gsub(/\s+/, " ")
           .strip
  end
end
