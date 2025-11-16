class Api::Recipes::NewFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def recipe
    @recipe ||= Recipe.create!(name: @params[:title]).tap do |recipe|
      recipe.image.attach(@params[:image]) if @params[:image].present?
      recipe.build_user_recipe(user: @user)
      build_instructions(recipe)
      BuildRecipeIngredients.call(recipe.id, parsed_ingredients)
    end
  end

  def build_instructions(recipe)
    return [] if @params[:steps].blank?
    @params[:steps] = @params[:steps].map(&:strip).reject(&:empty?)
    @params[:steps]&.each_with_index do |instruction, index|
      recipe.recipe_instructions.new(step_number: index + 1, instruction: instruction)
    end
  end

  def parsed_ingredients
    # trim whitespace and remove empty strings
    return [] if @params[:ingredients].blank?
    @params[:ingredients] = @params[:ingredients].map(&:strip).reject(&:empty?)
    @params[:ingredients]&.map do |ing|
      ParseIngredient.new(ing).to_h
    end
  end
end
