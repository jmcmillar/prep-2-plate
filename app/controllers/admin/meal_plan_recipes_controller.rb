class Admin::MealPlanRecipesController < AuthenticatedController
  def index
    @facade = Admin::MealPlanRecipes::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::MealPlanRecipes::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::MealPlanRecipes::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::MealPlanRecipes::NewFacade.new(Current.user, params)
    @facade.meal_plan_recipe.assign_attributes(meal_plan_recipe_params)

    if @facade.meal_plan_recipe.save
      redirect_to admin_meal_plan_meal_plan_recipes_url(@facade.meal_plan), notice: "Meal plan recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::MealPlanRecipes::EditFacade.new(Current.user, params)
    @facade.meal_plan_recipe.assign_attributes(meal_plan_recipe_params)

    if @facade.meal_plan_recipe.save
      redirect_to admin_meal_plan_meal_plan_recipes_url(@facade.meal_plan), notice: "Meal plan recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::MealPlanRecipes::DestroyFacade.new(Current.user, params)
    @facade.meal_plan_recipe.destroy
    set_destroy_flash_for(@facade.meal_plan_recipe)
  end
  
  def meal_plan_recipe_params
    params.require(:meal_plan_recipe).permit(:recipe_id, :day_sequence, :date)
  end
end
