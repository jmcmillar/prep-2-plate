class Api::RecipeImports::NewFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def recipe
    recipe_record.tap do |recipe|
      build_instructions(recipe)
      build_ingredients(recipe)
      attach_image(recipe)
    end
  end

  def build_instructions(recipe)
    parsed_recipe[:instructions]&.each_with_index do |instruction, index|
      recipe.recipe_instructions.new(
        step_number: index + 1,
        instruction: instruction
      )
    end
  end

  def build_ingredients(recipe)
    parsed_recipe[:ingredients]&.each do |ingredient|
      parsed_recipe = ParseIngredient.new(ingredient).to_h
      quantity = QuantityFactory.new(parsed_recipe[:quantity]).create

      # Skip if ingredient name is blank
      next if parsed_recipe[:ingredient_name].blank?

      recipe.recipe_ingredients.new(
        ingredient: Ingredient.find_or_create_by(name: parsed_recipe[:ingredient_name].strip.downcase),
        quantity: parsed_recipe[:quantity],
        measurement_unit_id: parsed_recipe[:measurement_unit_id],
        numerator: quantity.numerator,
        denominator: quantity.denominator,
        notes: parsed_recipe[:ingredient_notes]
      )
    end
  end

  def recipe_record
    @recipe ||= Recipe.new(
      serving_size: parsed_recipe[:yield]&.to_i,
      duration_minutes: parsed_recipe[:total_time],
      name: parsed_recipe[:name],
      description: parsed_recipe[:description],
      recipe_import: recipe_import
    )
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(@params[:url]).to_h
  end

  def recipe_import
    @recipe_import ||= RecipeImport.find_or_create_by(url: @params[:url])
  end

  def attach_image(recipe)
    return if parsed_recipe[:image_url].blank?

    begin
      require 'open-uri'

      image_url = parsed_recipe[:image_url]
      downloaded_image = URI.open(image_url)

      # Extract filename from URL or use a default
      filename = File.basename(URI.parse(image_url).path).presence || "recipe_image.jpg"

      recipe.image.attach(
        io: downloaded_image,
        filename: filename,
        content_type: downloaded_image.content_type
      )
    rescue => e
      Rails.logger.error "Failed to attach image from URL #{parsed_recipe[:image_url]}: #{e.message}"
      # Continue without image rather than failing the whole import
    end
  end
end
