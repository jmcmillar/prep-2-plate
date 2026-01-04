class Admin::UserMealPlans::DestroyFacade < Base::Admin::DestroyFacade
  def user_meal_plan
    @user_meal_plan ||= UserMealPlan.find(@params[:id])
  end
end
