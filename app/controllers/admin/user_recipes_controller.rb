class Admin::UserRecipesController < AuthenticatedController
  def index
    @facade = Admin::UserRecipes::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::UserRecipes::ShowFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::UserRecipes::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Admin::UserRecipes::EditFacade.new(Current.user, params)
    @facade.user_recipe.assign_attributes(recipe_params)
    if @facade.user_recipe.update!(recipe_params)
      redirect_to admin_user_recipe_url(@facade.user_recipe), notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::UserRecipes::DestroyFacade.new(Current.user, params)
    @facade.user_recipe.destroy
    set_destroy_flash_for(@facade.user_recipe)
  end

  private

  def recipe_params
    params.require(:user_recipe).permit(
      recipe_attributes: [
        :name, :image, :description, :serving_size, :duration_minutes, :difficulty_level, 
        recipe_category_ids: [], 
        meal_type_ids: []
      ]
    )
  end
end
