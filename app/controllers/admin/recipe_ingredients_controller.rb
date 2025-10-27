class Admin::RecipeIngredientsController < AuthenticatedController
  def index
    @facade = Admin::RecipeIngredients::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::RecipeIngredients::NewFacade.new(Current.user, params)
  end


  def create
    @facade = Admin::RecipeIngredients::NewFacade.new(Current.user, params, strong_params: ingredient_params)
    @facade.recipe_ingredient.assign_attributes(@facade.strong_params)
    if @facade.recipe_ingredient.save
      redirect_to admin_recipe_recipe_ingredients_url(@facade.recipe), notice: "Recipe Ingredient was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @facade = Admin::RecipeIngredients::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Admin::RecipeIngredients::EditFacade.new(Current.user, params, strong_params: ingredient_params)
    @facade.recipe_ingredient.assign_attributes(@facade.strong_params)
    if @facade.recipe_ingredient.update(ingredient_params)
      redirect_to admin_recipe_recipe_ingredients_url(@facade.recipe), notice: "Recipe Ingredient was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::RecipeIngredients::DestroyFacade.new(Current.user, params)
    @facade.recipe_ingredient.destroy
    set_destroy_flash_for(@facade.recipe_ingredient)
  end

  private

  def ingredient_params
    params.require(:recipe_ingredient).permit(:ingredient_id, :measurement_unit_id, :numerator, :denominator, :quantity, :notes)
  end
end
