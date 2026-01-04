class Admin::UserMealPlansController < AuthenticatedController
  def index
    @facade = Admin::UserMealPlans::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::UserMealPlans::ShowFacade.new(Current.user, params)
  end

  def destroy
    @facade = Admin::UserMealPlans::DestroyFacade.new(Current.user, params)
    @facade.user_meal_plan.destroy
    set_destroy_flash_for(@facade.user_meal_plan)
  end
end
