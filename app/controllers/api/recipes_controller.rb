class Api::RecipesController < Api::BaseController
  def index
    @recipes = Recipe.includes(:recipe_instructions).with_attached_image
  end

  def show
    @facade = Api::Recipes::ShowFacade.new(Current.user, params)
  end

  def create
    @facade = Api::Recipes::NewFacade.new(Current.user, recipe_params)
    if @facade.recipe.save
      render json: { message: 'Recipe created successfully', recipe: @facade.recipe }, status: :created
    else
      render json: { errors: @facade.recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @facade = Api::Recipes::EditFacade.new(Current.user, params, strong_params: recipe_params)
    if @facade.recipe.save
      render json: { message: 'Recipe updated successfully', recipe: @facade.recipe }
    else
      render json: { errors: @facade.recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title, :image, ingredients: [], steps: []
    )
  end
end
