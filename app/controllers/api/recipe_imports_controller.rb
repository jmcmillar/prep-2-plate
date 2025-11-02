class Api::RecipeImportsController < Api::BaseController
  def show
    @facade = Api::RecipeImports::ShowFacade.new(current_user, params)
  end
  
  def create
    @facade = Api::RecipeImports::NewFacade.new(current_user, import_params)
    if @facade.recipe.save
      UserRecipe.create!(recipe: @facade.recipe, user: current_user)
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
