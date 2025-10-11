class Admin::RecipesController < AuthenticatedController
  def index
    @facade = Admin::Recipes::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::Recipes::ShowFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Recipes::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Recipes::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Recipes::NewFacade.new(Current.user, params)
    @facade.recipe.assign_attributes(recipe_params)
    if @facade.recipe.save
      redirect_to admin_recipe_url(@facade.recipe), notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Recipes::EditFacade.new(Current.user, params)
    @facade.recipe.assign_attributes(recipe_params)
    if @facade.recipe.update!(recipe_params)
      redirect_to admin_recipe_url(@facade.recipe), notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Recipes::DestroyFacade.new(Current.user, params)
    @facade.recipe.destroy
    set_destroy_flash_for(@facade.recipe)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :image, :description, :serving_size, :duration_minutes, :difficulty_level, :featured, recipe_category_ids: [], meal_type_ids: [])
  end
end
