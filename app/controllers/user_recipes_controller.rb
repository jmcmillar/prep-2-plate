class UserRecipesController < AuthenticatedController
  layout 'application'
  
  def new
    @facade = UserRecipes::NewFacade.new(Current.user, params)
  end

  def create
    @facade = UserRecipes::NewFacade.new(Current.user, params)
    @facade.user_recipe.assign_attributes(user_recipe_params)

    if @facade.user_recipe.save
      redirect_to [:meal_planner, :recipes], notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def user_recipe_params
    params.require(:user_recipe).permit(
      recipe_attributes: [
        :name, :image, :description, :serving_size, :duration_minutes, :difficulty_level, recipe_category_ids: [], meal_type_ids: []
      ]
    )
  end
end
