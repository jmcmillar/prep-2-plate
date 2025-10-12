class Import::ParserSelector
  def initialize(nokogiri_doc)
    nokogiri_doc = Nokogiri::HTML(nokogiri_doc) if nokogiri_doc.is_a?(String)
    @nokogiri_doc = nokogiri_doc
  end

  def parser
    parser_classes = [
      Import::Parsers::NonStandard::JamieOliverParser,
      Import::Parsers::NonStandard::RachaelrayParser,
      Import::Parsers::JsonLdParser,
      Import::Parsers::SchemaOrgRecipeParser,
      Import::Parsers::HrecipeParser,
      Import::Parsers::DataVocabularyRecipeParser
    ]
    parser_classes.each do |parser_class|
      parser = parser_class.new(@nokogiri_doc)
      return parser if parser.can_parse?
    end
    Import::Parsers::NullRecipeParser.new(@nokogiri_doc)
  end
end
