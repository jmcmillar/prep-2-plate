class Import::Parsers::NonStandard::TasteOfHomeParser < Import::Parsers::SchemaOrgRecipeParser
  def self.root_selector
    '[itemtype*="schema.org/recipe"]'
  end

  def can_parse?
    canonical_url_matches_domain?('tasteofhome.com')
  end

  def parse_name
    nokogiri_doc.css('meta[itemprop="name"]').first['content']
  end

  def parse_yield
    value(node_with_itemprop("recipeyield")&.content)
  end
end
