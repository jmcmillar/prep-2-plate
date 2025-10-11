class Admin::MealTypes::DestroyFacade < Base::Admin::DestroyFacade
  def meal_type
    @meal_type ||= MealType.find(params[:id])
  end
end
