class Import::Parsers::NullRecipeParser < Import::Parsers::BaseParser
  def can_parse?(*)
    true
  end

  def initialize(*)
  end

  def parse
    Parser::NullRecipeData.new
  end
end
