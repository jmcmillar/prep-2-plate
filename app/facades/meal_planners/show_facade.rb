class MealPlanners::ShowFacade < BaseFacade
  def selected_recipes
    Recipe.where(id: @session[:selected_recipe_ids]).with_attached_image.map do |recipe|
      Recipes::ResourceFacade.new(recipe)
    end
  end

  def plan
    @session.fetch(:meal_plan, {})
  end

  def export_button_data
    ModalButtonComponent::Data[
      "Shopping List",
      [:new, :meal_planner, :export_to_shopping_list],
      :clipboard_list
    ]
  end

  def previous_week_link_data
    ButtonLinkComponent::Data[
      "Prev",
      [:meal_planner, {start_on: start_on.prev_week.beginning_of_week, end_on: end_on.prev_week.end_of_week}],
      :chevron_left,
      :primary,
    ]
  end

  def next_week_link_data
    ButtonLinkComponent::Data[
      "Next",
      [:meal_planner, {start_on: start_on.next_week.beginning_of_week, end_on: end_on.next_week.end_of_week}],
      :chevron_right,
      :primary,
      {class: "flex flex-row-reverse items-center gap-1"}
    ]
  end

  def active_key
    :meal_planner
  end

  def current_week
    start_on..end_on
  end

  private

  def start_on
    @params[:start_on]&.to_date || Date.current.beginning_of_week
  end

  def end_on
    @params[:end_on]&.to_date || Date.current.end_of_week
  end
end
