require 'open-uri'
class ParseRecipe
  def initialize(url)
    @url = HTTParty.get(url)
  end

  def to_h
    Parser.parse(@url).to_h
  end
end
