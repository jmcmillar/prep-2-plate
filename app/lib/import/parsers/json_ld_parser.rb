class Import::Parsers::JsonLdParser < Import::Parsers::SchemaOrgRecipeParser
  attr_accessor :nokogiri_doc, :recipe

  def self.root_selector
    'script[type="application/ld+json"]'
  end

  def initialize(nokogiri_doc)
    self.nokogiri_doc = nokogiri_doc
  end

  def can_parse?
    !recipe_hash.nil?
  end

  def recipe_hash
    return @recipe_hash if defined?(@recipe_hash)
    @recipe_hash = parse_recipe_hash
  end

  def nutrition_hash
    return @nutrition_hash if defined?(@nutrition_hash)
    @nutrition_hash = recipe_hash && recipe_hash['nutrition']
  end

  private

  def parse_recipe_hash
    json_ld_documents.each do |json|
      recipe = find_recipe_in(json)
      return recipe if recipe
    end
    nil
  end

  def json_ld_documents
    nokogiri_doc.css(self.class.root_selector).flat_map do |script|
      [ load_json(script.content) ].flatten.select { |json| json.is_a?(Hash) && schema_org?(json) }
    end
  end

  def load_json(content)
    Oj.load(content.strip.chomp(';').gsub(/\A<!--|-->\z/, ""))
  rescue Oj::ParseError, EncodingError
    nil
  end

  # @context can be a string, a hash ({"@vocab": "https://schema.org/"}) or an array
  def schema_org?(json)
    json['@context'].to_s.match?(/schema\.org/)
  end

  def find_recipe_in(json)
    return json if is_a_recipe?(json)

    candidates = [ json['mainEntity'], json['mainEntityOfPage'], *Array(json['@graph']) ]
    candidates.flatten.compact.find { |item| item.is_a?(Hash) && is_a_recipe?(item) }
  end

  def is_a_recipe?(json)
    Array(json['@type']).include?('Recipe') && contains_required_keys?(json)
  end

  def contains_required_keys?(json)
    json.key?('name') && (json.key?('recipeIngredient') || json.key?('ingredients'))
  end

  def nodes_with_itemprop(itemprop)
    recipe_hash ? recipe_hash[itemprop.to_s] : NullObject.new
  end

  def nutrition_node_with_itemprop(itemprop)
    return NullObject.new unless nutrition_hash
    nutrition_hash[itemprop].first || NullObject.new
  end

  def node_with_itemprop(itemprop)
    nodes = nodes_with_itemprop(itemprop)
    if nodes.nil?
      NullObject.new
    elsif nodes.is_a?(Array)
      nodes.first
    else
      nodes
    end
  end

  def parse_author
    author = node_with_itemprop(:author)
    case author
    when Hash then author["name"]
    when String then author
    end
  end

  def parse_description
    clean(node_with_itemprop(:description))
  end

  def parse_ingredients
    ingredients = nodes_with_itemprop('recipeIngredient') || nodes_with_itemprop('ingredients')
    Array(ingredients).flatten.grep(String).map { |ingredient| clean(ingredient) }.reject(&:blank?)
  end

  def parse_name
    clean(node_with_itemprop(:name))
  end

  def clean(text)
    text.is_a?(String) ? RecipeUtils::CleanText.call(text) : text
  end

  def parse_published_date
    content = node_with_itemprop(:datePublished)
    content.blank? ? nil : Date.parse(content)
  end

  def parse_yield
    value(node_with_itemprop(:recipeYield)) || NullObject.new
  end

  def parse_time(type)
    node = node_with_itemprop(type)
    parse_duration(node)
  end

  def nutrition_node_with_itemprop(itemprop)
    return NullObject.new unless nutrition_hash
    nutrition_hash[itemprop.to_s] || nil
  end

  def nutrition_property_value(itemprop)
    nutrition_node = nutrition_node_with_itemprop(itemprop)
    nutrition_node.is_a?(String) ? nutrition_node.strip : nutrition_node
  end

  def parse_instructions
    # Some sites like may have their recipe instructions doubled if they
    # support different ways of presentation.
    # E.g. http://www.pillsbury.com/recipes/big-cheesy-pepperoni-pockets/a17766e6-30ce-4a0c-af08-72533bb9b449
    # has its steps doubled ("step by step" and "list" modes).
    nodes = [ nodes_with_itemprop(:recipeInstructions) ].flatten
    parse_list_to_text(*nodes).map { |step| clean(step) }.reject(&:blank?).uniq
  end

  # Flattens strings, HowToStep, HowToSection, ItemList and ListItem nodes
  # into plain step text. Section headings are not steps, so they are dropped.
  def parse_list_to_text(*nodes)
    nodes.flat_map do |node|
      case node
      when String then split_text_steps(node)
      when Hash then parse_to_list(node)
      else []
      end
    end
  end

  def parse_to_list(node)
    children = node["itemListElement"] || node["steps"]
    return parse_list_to_text(*Array(children)) if children.present?

    step_text = node["text"] || node["name"] || node.dig("item", "text") || node.dig("item", "name")
    step_text.is_a?(String) ? [ step_text ] : []
  end

  # A single string may hold every step separated by newlines or <li>/<p> tags.
  def split_text_steps(text)
    text.split(%r{\r?\n+|</?(?:li|p|br)\s*/?>}i).map(&:strip).reject(&:blank?)
  end

  def parse_image_url
    image = nodes_with_itemprop(:image)
    image = image.first if image.is_a?(Array)
    image = image["url"] || image["contentUrl"] || image["@id"] if image.is_a?(Hash)
    image.is_a?(String) && image.start_with?("http") ? image : nil
  end
end
