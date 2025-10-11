class MealPlanner::ExportToShoppingLists::NewFacade < BaseFacade
  def shopping_list
    (ShoppingList.find_by(id: shopping_list_id) || @user.shopping_lists.new(name: "Main Shopping List")).tap do |list|
      return if @strong_params.empty?
      @strong_params[:shopping_list_items_attributes].each do |key, value|
        list.shopping_list_items.new(name: value["name"]) if key.present?
      end
    end
  end
  
  def shopping_lists
    @user.shopping_lists.order(:name)
  end

  def recipes
    Recipe.where(id: @session[:selected_recipe_ids])
  end

  def ingredients
    RecipeIngredient.where(recipe_id: recipes.pluck(:id))
  end

  def active_key
    :meal_plans
  end

  def form_url
    [meal_plan, :export_to_shopping_list]
  end

  def cancel_path
    [meal_plan]
  end

  def shopping_list_id
    @strong_params[:shopping_list_id] if @strong_params 
  end
end
