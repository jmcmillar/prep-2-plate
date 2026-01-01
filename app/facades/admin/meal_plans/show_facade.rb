class Admin::MealPlans::ShowFacade < Base::Admin::ShowFacade
  def initialize(user, params)
    @user = user
    @params = params
  end

  def active_key
    :admin_meal_plans
  end

  def recipe_ingredients
    IngredientFullNameDecorator.decorate_collection(meal_plan.recipe_ingredients)
  end

  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:id])
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Meal Plans", [:admin, :meal_plans]),
      BreadcrumbComponent::Data.new(meal_plan.name)
    ]
  end

  def header_actions
    [export_meal_plan_data, edit_action_data]
  end

  def export_meal_plan_data
    IconLinkComponent::Data[
      [:new, :admin, meal_plan, :meal_plan_export],
      :file_export, 
      "Export Meal Plan",
      {remote: true}
    ]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, meal_plan],
      :edit, 
      "Edit Meal Plan",
    ]
  end
end
