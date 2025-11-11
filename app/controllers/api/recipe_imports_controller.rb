class Api::RecipeImportsController < Api::BaseController
  def show
    @facade = Api::RecipeImports::ShowFacade.new(Current.user, params)
  end
  
  def create
    @facade = Api::RecipeImports::NewFacade.new(Current.user, import_params)
    if @facade.recipe.save
      UserRecipe.create!(recipe: @facade.recipe, user: Current.user)
      render json: @facade.recipe, status: :created
    else
      render json: { errors: @facade.recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def import_params
    params.require(:recipe_import).permit(:url)
  end
end
