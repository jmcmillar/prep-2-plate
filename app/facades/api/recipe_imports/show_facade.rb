class Api::RecipeImports::ShowFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def recipe
    @parsed_recipe ||= ParseRecipe.new(@params[:url]).to_h
  end
end
