class Admin::RecipeImports::RecipesController < AuthenticatedController
  def new
    @facade = Admin::RecipeImports::Recipes::NewFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::RecipeImports::Recipes::NewFacade.new(Current.user, params)
    @facade.recipe.assign_attributes(recipe_params)
    
    if @facade.recipe.save
      redirect_to new_admin_recipe_import_ingredient_url(@facade.recipe), notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, 
      :serving_size,
      :duration_minutes,
      recipe_instructions_attributes: [:id, :step_number, :instruction, :_destroy]
    )
  end
end
