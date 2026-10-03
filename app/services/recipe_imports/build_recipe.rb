# Builds an unsaved Recipe, with its instructions and ingredients, from the
# hash returned by ParseRecipe#to_h. Nothing is written to the database until
# the caller saves the recipe; ingredients are resolved by RecipeIngredient's
# before_validation callback inside that save's transaction, so a failed save
# leaves no orphan Ingredient rows.
class RecipeImports::BuildRecipe
  include Service

  # The source image is always linked on the import; attach_image also copies
  # it into storage.
  # with_ingredients: false suits flows that review ingredients in a later step.
  def initialize(parsed_recipe, recipe_import:, attach_image: true, with_ingredients: true,
                 ingredient_parser: RecipeImports::ParseIngredientLines)
    @parsed = parsed_recipe.to_h.with_indifferent_access
    @recipe_import = recipe_import
    @attach_image = attach_image
    @with_ingredients = with_ingredients
    @ingredient_parser = ingredient_parser
  end

  def call
    Recipe.new(recipe_attributes).tap do |recipe|
      build_instructions(recipe)
      build_ingredients(recipe) if @with_ingredients
      link_image
      RecipeImports::AttachImage.call(recipe, @parsed[:image_url]) if @attach_image
    end
  end

  private

  # Saved with the recipe (Recipe autosaves its import), so recipes without
  # an uploaded copy can show the source page's image
  def link_image
    @recipe_import.image_url = @parsed[:image_url] if @parsed[:image_url].present?
  end

  def recipe_attributes
    {
      name: @parsed[:name],
      description: @parsed[:description],
      serving_size: RecipeUtils::ParseServings.call(@parsed[:yield]),
      duration_minutes: RecipeUtils::TotalMinutes.call(@parsed),
      recipe_import: @recipe_import
    }
  end

  def build_instructions(recipe)
    Array(@parsed[:instructions]).each_with_index do |instruction, index|
      recipe.recipe_instructions.new(step_number: index + 1, instruction: instruction)
    end
  end

  def build_ingredients(recipe)
    @ingredient_parser.call(@parsed[:ingredients]).each do |ingredient|
      next if ingredient[:ingredient_name].blank?

      recipe.recipe_ingredients.new(ingredient_attributes(ingredient))
    end
  end

  def ingredient_attributes(ingredient)
    quantity = QuantityFactory.new(ingredient[:quantity].to_s).create
    {
      ingredient_name: ingredient[:ingredient_name],
      packaging_form: ingredient[:packaging_form],
      preparation_style: ingredient[:preparation_style],
      measurement_unit_id: ingredient[:measurement_unit_id],
      numerator: quantity.numerator,
      denominator: quantity.denominator,
      notes: ingredient[:ingredient_notes].presence
    }
  end
end
