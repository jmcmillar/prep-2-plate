class Admin::MealPlansController < AuthenticatedController
  def index
    @facade = Admin::MealPlans::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::MealPlans::NewFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::MealPlans::ShowFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::MealPlans::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::MealPlans::NewFacade.new(Current.user, params)
    @facade.meal_plan.assign_attributes(meal_plan_params)

    if @facade.meal_plan.save
      redirect_to admin_meal_plan_url(@facade.meal_plan), notice: "Meal plan was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::MealPlans::EditFacade.new(Current.user, params)
    @facade.meal_plan.assign_attributes(meal_plan_params)
    if @facade.meal_plan.update!(meal_plan_params)
      redirect_to admin_meal_plan_url(@facade.meal_plan), notice: "Meal plan was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::MealPlans::DestroyFacade.new(Current.user, params)
    @facade.meal_plan.destroy
    set_destroy_flash_for(@facade.meal_plan)
  end

  private

  def meal_plan_params
    params.require(:meal_plan).permit(:name, :description, :featured)
  end
end
