
class Import::Parsers::NonStandard::JamieOliverParser < Import::Parsers::JsonLdParser
  def can_parse?
    nokogiri_doc.css('meta[name="author"]').first['content'] == "JamieOliver.com"
  rescue NoMethodError
    false
  end

  private

  def parse_author
    "Jamie Oliver"
  end

  def parse_instructions
    # JamieOliver.com has html inside json ld recipeInstructions node
    nodes = nodes_with_itemprop(:recipeInstructions)
    nodes = [nodes].flatten
    html = nodes.map(&:strip).uniq
    Nokogiri::HTML(html.gsub(/<\/li><li>/, "\n")).content
  end
end
