class Admin::MealTypesController < AuthenticatedController
  def index
    @facade = Admin::MealTypes::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::MealTypes::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::MealTypes::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::MealTypes::NewFacade.new(Current.user, params)
    @facade.meal_type.assign_attributes(meal_type_params)
    if @facade.meal_type.save
      redirect_to admin_meal_types_url, notice: "Meal type was successfully created."
    else
      render :new, status: :unprocessable
    end
  end

  def update
    @facade = Admin::MealTypes::EditFacade.new(Current.user, params)
    @facade.meal_type.assign_attributes(meal_type_params)
    if @facade.meal_type.update!(meal_type_params)
      redirect_to admin_meal_types_url, notice: "Meal type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::MealTypes::DestroyFacade.new(Current.user, params)
    @facade.meal_type.destroy
    set_destroy_flash_for(@facade.meal_type)
  end
  
  private

  def meal_type_params
    params.require(:meal_type).permit(:name)
  end
end
