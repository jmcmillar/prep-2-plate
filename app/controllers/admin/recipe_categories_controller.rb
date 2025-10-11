class Admin::RecipeCategoriesController < AuthenticatedController
  def index
    @facade = Admin::RecipeCategories::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::RecipeCategories::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::RecipeCategories::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::RecipeCategories::NewFacade.new(Current.user, params)
    @facade.recipe_category.assign_attributes(recipe_category_params)

    if @facade.recipe_category.save
      redirect_to admin_recipe_categories_url, notice: "recipe category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::RecipeCategories::EditFacade.new(Current.user, params)
    @facade.recipe_category.assign_attributes(recipe_category_params)
    if @facade.recipe_category.update(recipe_category_params)
      redirect_to admin_recipe_categories_url, notice: "recipe category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::RecipeCategories::DestroyFacade.new(Current.user, params)
    @facade.recipe_category.destroy
    set_destroy_flash_for(@facade.recipe_category)
  end

  private

  def recipe_category_params
    params.require(:recipe_category).permit(:name, :image)
  end
end
