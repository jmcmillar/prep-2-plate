class Api::RecipesController < Api::BaseController
  def index
    @recipes = Recipe.all.with_attached_image
  end

  def show
    @facade = Api::Recipes::ShowFacade.new(current_user, params)
  end

  def create
    @facade = Api::Recipes::NewFacade.new(current_user, recipe_params)
    if @facade.recipe.save
      render json: { message: 'Recipe created successfully', recipe: @facade.recipe }, status: :created
    else
      render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def recipe_params
    params.require(:recipe).permit(
      :title, :imageUri, ingredients: [], steps: []
    )
  end
end
