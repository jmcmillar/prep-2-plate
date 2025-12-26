class MealPlans::ExportToShoppingLists::NewFacade < BaseFacade
  def shopping_list
    (ShoppingList.find_by(id: shopping_list_id) || @user.shopping_lists.new(name: "Main Shopping List")).tap do |list|
      return if @strong_params.empty?
      @strong_params[:shopping_list_items_attributes]&.each do |key, value|
        next unless key.present?
        list.shopping_list_items.new(
          name: value[:name] || value["name"],
          ingredient_id: value[:ingredient_id] || value["ingredient_id"],
          packaging_form: value[:packaging_form] || value["packaging_form"],
          preparation_style: value[:preparation_style] || value["preparation_style"]
        )
      end
    end
  end
  
  def shopping_lists
    @user.shopping_lists.order(:name)
  end

  def meal_plan
    @meal_plan ||= MealPlan.find(params[:meal_plan_id])
  end

  def ingredients
    MealPlanIngredient.where(meal_plan_id: meal_plan.id)
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
