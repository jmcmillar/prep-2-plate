class MealPlans::ExportToShoppingListsController < AuthenticatedController
  def new
    @facade = MealPlans::ExportToShoppingLists::NewFacade.new(Current.user, params, session: session)
  end

  def create
    @facade = MealPlans::ExportToShoppingLists::NewFacade.new(Current.user, params, session: session, strong_params: export_to_shopping_list_params)
    if @facade.shopping_list.save
      redirect_to meal_plan_url(@facade.meal_plan), notice: "Shopping list was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def export_to_shopping_list_params
    params.require(:shopping_list).permit(:shopping_list_id, shopping_list_items_attributes: [:name])
  end
end
