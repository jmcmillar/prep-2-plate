class Admin::UserMealPlanRecipesController < AuthenticatedController
  def index
    @facade = Admin::UserMealPlanRecipes::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::UserMealPlanRecipes::ShowFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::UserMealPlanRecipes::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Admin::UserMealPlanRecipes::EditFacade.new(Current.user, params)
    if @facade.meal_plan_recipe.update(meal_plan_recipe_params)
      redirect_to [:admin, @facade.user_meal_plan], notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::UserMealPlanRecipes::DestroyFacade.new(Current.user, params)
    @facade.meal_plan_recipe.destroy
    set_destroy_flash_for(@facade.meal_plan_recipe)
  end

  private

  def meal_plan_recipe_params
    params.require(:meal_plan_recipe).permit(:recipe_id, :date, :day_sequence)
  end
end
