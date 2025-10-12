module Parser
  RECIPE_ATTRIBUTES = [
    :author,
    :canonical_url,
    :cook_time,
    :description,
    :image_url,
    :ingredients,
    :instructions,
    :name,
    :nutrition,
    :prep_time,
    :published_date,
    :total_time,
    :yield
  ]

  NUTRITION_ATTRIBUTES = [
    :calories,
    :cholesterol,
    :fiber,
    :protein,
    :saturated_fat,
    :sodium,
    :sugar,
    :total_carbohydrates,
    :total_fat,
    :trans_fat,
    :unsaturated_fat
  ]

  RecipeData = Struct.new(*RECIPE_ATTRIBUTES)

  class NullRecipeData < RecipeData
    def nil?
      true
    end
  end

  def self.parse(html)
    recipe = parser_for(html).parse
  end

  def self.parser_for(html)
    html = html.read if html.respond_to?(:read)
    html = html.sub("\xEF\xBB\xBF", "") # Remove the UTF-8 Byte-Order Mark (BOM)
    nokogiri_doc = Nokogiri::HTML(html)
    Import::ParserSelector.new(nokogiri_doc).parser
  end
end
