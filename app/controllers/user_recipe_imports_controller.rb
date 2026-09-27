class UserRecipeImportsController < AuthenticatedController
  layout 'application'
  
  def new
    @facade = UserRecipeImports::NewFacade.new(Current.user, params)
  end

  def create
    @facade = UserRecipeImports::NewFacade.new(Current.user, params, strong_params: user_recipe_params)

    if @facade.save
      redirect_to [:my_recipes], notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_recipe_params
    params.require(:recipe_import).permit(:url)
  end
end
