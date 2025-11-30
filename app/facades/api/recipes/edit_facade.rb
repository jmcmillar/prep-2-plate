class Api::Recipes::EditFacade
  def initialize(user, params, **options)
    @user = user
    @params = params
    @strong_params = options[:strong_params]
  end

  def recipe
    @recipe ||= Recipe.includes(:user_recipe).where(user_recipe: { user_id: @user.id }).find(@params[:id]).tap do |recipe|
      recipe.name = @strong_params[:title] if @strong_params[:title].present?
      recipe.image.attach(@strong_params[:image]) if @strong_params[:image].present?
      update_instructions(recipe)
      update_ingredients(recipe)
    end
  end

  private

  def update_instructions(recipe)
    return if @strong_params[:steps].blank?
    
    # Remove old instructions
    recipe.recipe_instructions.destroy_all
    
    # Add new instructions
    steps = @strong_params[:steps].map(&:strip).reject(&:empty?)
    steps&.each_with_index do |instruction, index|
      recipe.recipe_instructions.build(step_number: index + 1, instruction: instruction)
    end
  end

  def update_ingredients(recipe)
    return if @strong_params[:ingredients].blank?
    
    # Remove old ingredients
    recipe.recipe_ingredients.destroy_all
    
    # Add new ingredients
    BuildRecipeIngredients.call(recipe.id, parsed_ingredients)
  end

  def parsed_ingredients
    return [] if @strong_params[:ingredients].blank?
    ingredients = @strong_params[:ingredients].map(&:strip).reject(&:empty?)
    ingredients&.map do |ing|
      ParseIngredient.new(ing).to_h
    end
  end
end
