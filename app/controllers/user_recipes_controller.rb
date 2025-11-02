class UserRecipesController < AuthenticatedController
  layout 'application'
  
  def new
    @facade = UserRecipes::NewFacade.new(Current.user, params)
  end

  def create
    @facade = UserRecipes::NewFacade.new(Current.user, params)
    
    processed_params = UserRecipes::ProcessParams.new(user_recipe_params).call
    
    @facade.user_recipe.assign_attributes(processed_params)

    if @facade.user_recipe.save
      redirect_to [:my_recipes], notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @facade = UserRecipes::EditFacade.new(Current.user, params)
  end

  def update
    @facade = UserRecipes::EditFacade.new(Current.user, params)
    
    processed_params = UserRecipes::ProcessParams.new(user_recipe_params).call
    
    @facade.user_recipe.assign_attributes(processed_params)

    if @facade.user_recipe.save
      redirect_to [:my_recipes], notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def user_recipe_params
    params.require(:user_recipe).permit(
      :id,
      recipe_attributes: [
        :id, :name, :image, :description, :serving_size, :duration_minutes, :difficulty_level, 
        recipe_category_ids: [], 
        meal_type_ids: [],
        recipe_ingredients_attributes: [
          :id, :ingredient_id, :ingredient_name, :measurement_unit_id, 
          :quantity, :notes, :_destroy
        ],
        recipe_instructions_attributes: [:id, :step_number, :instruction, :_destroy]
      ]
    )
  end
end
