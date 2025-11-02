class Api::ShoppingListItemsController < Api::BaseController
  def index
    @shopping_list_items = ShoppingListItem.where(shopping_list_id: params[:shopping_list_id]).order(created_at: :desc)
  end
  
  def create
    @shopping_list = ShoppingList.find(params[:shopping_list_id])
    @shopping_list_item = @shopping_list.shopping_list_items.new(shopping_list_item_params)
    
    if @shopping_list_item.save
      render json: @shopping_list_item, status: :created
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list_item = ShoppingListItem.find(params[:id])

    if @shopping_list_item.destroy
      render json: @shopping_list_item, status: :ok
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end

  private

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
