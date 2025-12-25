
class UserRecipeImports::NewFacade < BaseFacade
  DifficultyLevel = Struct.new(:name, :value)
  
  def recipe_import
    @recipe_import ||= RecipeImport.find_or_initialize_by(url: @strong_params[:url])
  end

  def form_url
    {
      controller: "user_recipe_imports",
      action: "create"
    }
  end

  def recipe
    recipe_record.tap do |recipe|
      unless valid?
        add_validation_errors
        return recipe
      end
      
      recipe.build_user_recipe(user: @user)
      build_instructions(recipe)
      build_ingredients(recipe)
    end
  end

  private

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
      parsed_ingredient = ParseIngredient.new(ingredient).to_h
      quantity = QuantityFactory.new(parsed_ingredient[:quantity]).create

      # Skip if ingredient name is blank
      next if parsed_ingredient[:ingredient_name].blank?

      recipe.recipe_ingredients.new(
        ingredient: Ingredient.find_or_create_by(
          name: parsed_ingredient[:ingredient_name].strip.downcase,
          packaging_form: parsed_ingredient[:packaging_form],
          preparation_style: parsed_ingredient[:preparation_style]
        ),
        quantity: parsed_ingredient[:quantity],
        measurement_unit_id: parsed_ingredient[:measurement_unit_id],
        numerator: quantity.numerator,
        denominator: quantity.denominator,
        notes: parsed_ingredient[:ingredient_notes]
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
    ).tap do |recipe|
      attach_image_from_url(recipe, parsed_recipe[:image_url])
    end
  end

  def valid?
    parsed_recipe[:name].present? && parsed_recipe[:ingredients].any? && parsed_recipe[:instructions].any?
  end

  def add_validation_errors
    recipe_import.errors.add(:base, "Could not parse recipe from URL. Recipe name is required.") unless parsed_recipe[:name].present?
    recipe_import.errors.add(:base, "Could not parse recipe from URL. Recipe must have at least one ingredient.") unless parsed_recipe[:ingredients]&.any?
    recipe_import.errors.add(:base, "Could not parse recipe from URL. Recipe must have at least one instruction.") unless parsed_recipe[:instructions]&.any?
  end

  def parsed_recipe
    @parsed_recipe ||= ParseRecipe.new(@strong_params[:url]).to_h
  end

  def attach_image_from_url(recipe, image_url)
  
    begin
      downloaded_image = URI.open(image_url)
      filename = File.basename(URI.parse(image_url).path)
      
      recipe.image.attach(
        io: downloaded_image,
        filename: filename,
        content_type: downloaded_image.content_type
      )
    rescue => e
      Rails.logger.error "Failed to attach image: #{e.message}"
      # Silently fail - don't break recipe import if image fails
    end
  end
end
