class Admin::RecipeImportsController < AuthenticatedController
  def new
    @facade = Admin::RecipeImports::NewFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::RecipeImports::NewFacade.new(Current.user, params)
    @facade.import.assign_attributes(recipe_import_params)
    if @facade.import.save
      redirect_to new_admin_recipe_import_recipe_url(@facade.import.id), notice: "Recipe Import was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def recipe_import_params
    params.require(:recipe_import).permit(:url)
  end
end
