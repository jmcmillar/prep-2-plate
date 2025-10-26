class ShoppingListItemsController < AuthenticatedController
  layout "application"
  before_action :set_shopping_list, only: %i[index create]

  def index
    @facade = ShoppingListItems::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = ShoppingListItems::NewFacade.new(Current.user, params)
  end

  def create
    item = @shopping_list.shopping_list_items.new(shopping_list_item_params)
    
    if item.save
      respond_to do |format|
        format.json { render json: { id: item.id, name: item.name }, status: :created }
        format.html do
          redirect_to shopping_list_items_url(@shopping_list), notice: "Item was successfully created."
        end
      end
    else
      respond_to do |format|
        format.json { render json: { errors: item.errors.full_messages }, status: :unprocessable_entity }
        format.html do
          @facade = ShoppingListItems::NewFacade.new(Current.user, params)
          @facade.shopping_list_item.assign_attributes(shopping_list_item_params)
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @facade = ShoppingListItems::EditFacade.new(Current.user, params)
  end

  def update
    @facade = ShoppingListItems::EditFacade.new(Current.user, params)

    if @facade.shopping_list_item.update(shopping_list_item_params)
      redirect_to shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = ShoppingListItems::DestroyFacade.new(Current.user, params)
    if @facade.shopping_list_item.destroy
      redirect_to shopping_list_items_url(@facade.shopping_list), notice: "Item was successfully deleted."
    end
    set_destroy_flash_for(@facade.shopping_list_item)
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name)
  end

  def set_shopping_list
    @shopping_list = Current.user.shopping_lists.find(params[:shopping_list_id])
  end
end
