class Api::ShoppingListsController < Api::BaseController
  def index
    @shopping_lists = ShoppingList.includes(:shopping_list_items).where(
      user_id: current_user.id
    )
  end

  def create
    @shopping_list = ShoppingList.new(name: params[:name], user: current_user)

    if @shopping_list.save
      render json: @shopping_list, status: :created
    else
      render json: @shopping_list.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list_item = ShoppingListItem.find(params[:id])

    if @shopping_list_item.destroy
      head :ok
    else
      render json: @shopping_list_item.errors, status: :unprocessable_entity
    end
  end
end
