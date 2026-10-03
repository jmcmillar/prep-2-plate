class Api::RecipeImportsController < Api::BaseController
  rescue_from ParseRecipe::FetchError, Import::SafeUrl::UnsafeUrlError, with: :import_failed

  def show
    @facade = Api::RecipeImports::ShowFacade.new(Current.user, params)
  end

  def create
    @facade = Api::RecipeImports::NewFacade.new(Current.user, import_params)
    return render json: @facade.recipe, status: :created if @facade.save

    render json: { errors: @facade.errors }, status: :unprocessable_entity
  end

  private

  def import_params
    params.require(:recipe_import).permit(:url, recipe_category_ids: [])
  end

  def import_failed(exception)
    render json: { errors: [ exception.message ] }, status: :unprocessable_entity
  end
end
