class MealPlans::ShowFacade < BaseFacade
  def resource
    MealPlan.find @params[:id]
  end

  def description
    resource.description
  end

  def name
    resource.name
  end

  def recipes
    resource.recipes.with_attached_image.map { |recipe| Recipes::ResourceFacade.new(recipe) }
  end

  def ingredients
   MealPlanIngredient::NameDecorator.decorate_collection(MealPlanIngredient.where(meal_plan_id: resource.id))
  end

  def active_key
    :meal_plans
  end

  def export_button_data
    return ModalButtonComponent::Data.new unless user.present?
    ModalButtonComponent::Data.new(
      "Export",
      [:new, resource, :export_to_shopping_list],
      :shopping_basket
    )
  end
end
