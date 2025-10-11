class Admin::ShoppingListItemsController < AuthenticatedController
  def index
    @facade = Admin::ShoppingListItems::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::ShoppingListItems::NewFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::ShoppingListItems::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::ShoppingListItems::NewFacade.new(Current.user, params)
    @facade.shopping_list_item.assign_attributes(shopping_list_item_params)

    if @facade.shopping_list_item.save
      redirect_to admin_shopping_list_shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::ShoppingListItems::EditFacade.new(Current.user, params)

    if @facade.shopping_list_item.update(shopping_list_item_params)
      redirect_to admin_shopping_list_shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::ShoppingListItems::DestroyFacade.new(Current.user, params)
    @facade.shopping_list_item.destroy
    set_destroy_flash_for(@facade.shopping_list_item)
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
