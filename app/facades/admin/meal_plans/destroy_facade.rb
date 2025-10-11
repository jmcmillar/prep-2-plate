class Admin::MealPlans::DestroyFacade < Base::Admin::DestroyFacade
  def meal_plan
    @meal_plan ||= MealPlan.find(@params[:id])
  end
end
