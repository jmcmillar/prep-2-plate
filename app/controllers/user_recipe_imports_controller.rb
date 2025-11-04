class UserRecipeImportsController < AuthenticatedController
  layout 'application'
  
  def new
    @facade = UserRecipeImports::NewFacade.new(Current.user, params)
  end

  def create
    @facade = UserRecipeImports::NewFacade.new(Current.user, params, strong_params: user_recipe_params)
    
    recipe = @facade.recipe
    
    ActiveRecord::Base.transaction do
      if recipe.errors.empty? && @facade.recipe_import.save && recipe.save
        redirect_to [:my_recipes], notice: "Recipe was successfully created."
      else
        raise ActiveRecord::Rollback
      end
    end
    
    render :new, status: :unprocessable_entity unless performed?
  end

  private

  def user_recipe_params
    params.require(:recipe_import).permit(:url)
  end
end
