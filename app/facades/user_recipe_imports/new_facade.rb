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
      parsed_recipe = ParseIngredient.new(ingredient).to_h
      quantity = QuantityFactory.new(parsed_recipe[:quantity]).create
      recipe.recipe_ingredients.new(
        ingredient: Ingredient.find_or_initialize_by(name: parsed_recipe[:ingredient_name]),
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
end
