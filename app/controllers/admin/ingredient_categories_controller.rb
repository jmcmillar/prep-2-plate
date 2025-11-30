class Admin::IngredientCategoriesController < AuthenticatedController
  def index
    @facade = Admin::IngredientCategories::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::IngredientCategories::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::IngredientCategories::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::IngredientCategories::NewFacade.new(Current.user, params)
    @facade.ingredient_category.assign_attributes(ingredient_category_params)

    if @facade.ingredient_category.save
      redirect_to admin_ingredient_categories_url, notice: "Ingredient category was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::IngredientCategories::EditFacade.new(Current.user, params)
    @facade.ingredient_category.assign_attributes(ingredient_category_params)
    if @facade.ingredient_category.update(ingredient_category_params)
      redirect_to admin_ingredient_categories_url, notice: "Ingredient category was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::IngredientCategories::DestroyFacade.new(Current.user, params)
    @facade.ingredient_category.destroy
    set_destroy_flash_for(@facade.ingredient_category)
  end

  private

  def ingredient_category_params
    params.require(:ingredient_category).permit(:name)
  end
end
