class Api::CurrentShoppingListsController < Api::BaseController
  def create
    user = Current.user
    shopping_list = user.shopping_lists.find(params[:shopping_list_id])
    if shopping_list.update(current: true) && user.shopping_lists.where.not(id: shopping_list.id).update_all(current: false)
      render json: shopping_list, status: :created
    else
      render json: shopping_list.errors, status: :unprocessable_entity
    end
  end
end
