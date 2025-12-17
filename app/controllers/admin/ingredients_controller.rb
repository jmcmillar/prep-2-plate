class Admin::IngredientsController < AuthenticatedController
  def index
    @facade = Admin::Ingredients::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::Ingredients::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::Ingredients::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::Ingredients::NewFacade.new(Current.user, params)
    @facade.ingredient.assign_attributes(ingredient_params)
    if @facade.ingredient.save
      redirect_to admin_ingredients_url, notice: "Ingredient was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::Ingredients::EditFacade.new(Current.user, params)
    @facade.ingredient.assign_attributes(ingredient_params)
    if @facade.ingredient.update!(ingredient_params)
      redirect_to admin_ingredients_url, notice: "Ingredient was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::Ingredients::DestroyFacade.new(Current.user, params)
    @facade.ingredient.destroy
    set_destroy_flash_for(@facade.ingredient)
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name, :ingredient_category_id)
  end
end
