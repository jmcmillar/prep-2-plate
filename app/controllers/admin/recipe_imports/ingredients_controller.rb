class Admin::RecipeImports::IngredientsController < AuthenticatedController
  before_action { set_active_menu :admin_recipes }
  
  def new
    @facade = Admin::RecipeImports::Ingredients::NewFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::RecipeImports::Ingredients::NewFacade.new(Current.user, params)

    if @facade.build_ingredient_list
      redirect_to admin_recipes_url, notice: "Recipe Ingredients were successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ingredient_params
    params.require(:recipe).permit(
      recipe_ingredients_attributes: [
        :quantity,
        :measurement_unit_id,
        :ingredient_name,
        :ingredient_notes
      ]
      )
  end
end
