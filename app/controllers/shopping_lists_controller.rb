class ShoppingListsController < AuthenticatedController
  layout "application"

  def index
    @facade = ShoppingLists::IndexFacade.new Current.user, params
  end

  def new
    @facade = ShoppingLists::NewFacade.new Current.user, params
  end

  def create
    @facade = ShoppingLists::NewFacade.new Current.user, params
    @facade.shopping_list.assign_attributes(shopping_list_params)
    if @facade.shopping_list.save
      redirect_to shopping_lists_path, notice: "Shopping list was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
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
    params.require(:shopping_list).permit(:current, :name)
  end
end
