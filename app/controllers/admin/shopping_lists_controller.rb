class Admin::ShoppingListsController < AuthenticatedController
  def index
    @facade = Admin::ShoppingLists::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::ShoppingLists::NewFacade.new(Current.user, params)
  end

  def show
    @facade = Admin::ShoppingLists::ShowFacade.new(Current.user, params)
  end

  def edit
    @facade = Admin::ShoppingLists::EditFacade.new(Current.user, params)
  end

  def create
    @facade = Admin::ShoppingLists::NewFacade.new(Current.user, params)
    @facade.shopping_list.assign_attributes(shopping_list_params)
    if @facade.shopping_list.save
      redirect_to admin_user_shopping_lists_url(@facade.user), notice: "Shopping List was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @facade = Admin::ShoppingLists::EditFacade.new(Current.user, params)
    @facade.shopping_list.assign_attributes(shopping_list_params)
    if @facade.shopping_list.save
      redirect_to admin_user_shopping_lists_url(@facade.user), notice: "Shopping List was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::ShoppingLists::DestroyFacade.new(Current.user, params)
    @facade.shopping_list.destroy
    set_destroy_flash_for(@facade.shopping_list)
  end

  private

  def shopping_list_params
    params.require(:shopping_list).permit(:name)
  end
end
