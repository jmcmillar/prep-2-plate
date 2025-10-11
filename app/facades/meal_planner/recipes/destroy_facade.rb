class MealPlanner::Recipes::DestroyFacade < BaseFacade
  def resource
    @resource ||= Recipe.find_by(id: @params[:id])
  end

  def selected_recipes
    Recipe.where(id: @session[:selected_recipe_ids]).map do |recipe|
      Recipes::ResourceFacade.new(recipe)
    end
  end

  def export_button_data
    ModalButtonComponent::Data[
      "Export Meal Plan",
      [:new, :meal_planner, :export_to_shopping_list],
      :shopping_basket
    ]
  end


  def remove_from_meal_plan
    @session[:meal_plan] ||= {}
    if @session[:meal_plan][@params[:day]]["recipes"]
      @session[:meal_plan][@params[:day]]["recipes"].reject! { |r| r["id"] == resource.id }
    end
  end

  def remove_from_selected_recipes
    @session[:selected_recipe_ids] ||= []
    @session[:selected_recipe_ids].delete(resource.id)
  end

  def plan
    @session[:meal_plan] ||= {}
  end

  def previous_week_link_data
    ButtonLinkComponent::Data[
      "Prev",
      [:meal_planner, {start_on: start_on.prev_week.beginning_of_week, end_on: end_on.prev_week.end_of_week}],
    ]
  end

  def next_week_link_data
    ButtonLinkComponent::Data[
      "Next",
      [:meal_planner, {start_on: start_on.next_week.beginning_of_week, end_on: end_on.next_week.end_of_week}],
    ]
  end

  def current_week
    start_on..end_on
  end

  def start_on
    recipe_date.beginning_of_week
  end

  def end_on
    recipe_date.end_of_week
  end

  def recipe_date
    @params[:day].to_date
  end

  def current_week
    recipe_date.beginning_of_week..recipe_date.end_of_week
  end
end
