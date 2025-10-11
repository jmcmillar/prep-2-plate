class ShoppingListsController < AuthenticatedController
  layout "application"

  def index
    @facade = ShoppingLists::IndexFacade.new Current.user, params
  end

  def show
    @facade = ShoppingLists::ShowFacade.new Current.user, params
  end

  def update
    @facade = ShoppingLists::EditFacade.new Current.user, params
    if @facade.shopping_list.update(current: true)
      @facade.set_others_false
      redirect_to shopping_lists_path, notice: "Shopping list was successfully updated."
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = ShoppingLists::ShowFacade.new Current.user, params
    @facade.resource.destroy
    redirect_to shopping_lists_path, notice: "Shopping list was successfully deleted."
  end

  def shopping_list_params
    params.require(:shopping_list).permit(:current)
  end
end
