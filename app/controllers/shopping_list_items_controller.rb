class ShoppingListItemsController < AuthenticatedController
  before_action :set_shopping_list

  def create
    item = @shopping_list.shopping_list_items.create(name: params[:name])
    if item.persisted?
      render json: { id: item.id, name: item.name }, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_shopping_list
    @shopping_list = current_user.shopping_lists.find(params[:shopping_list_id])
  end
end
