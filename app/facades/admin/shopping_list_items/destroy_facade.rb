class Admin::ShoppingListItems::DestroyFacade < Base::Admin::DestroyFacade
  def shopping_list_item
    @shopping_list_item ||= ShoppingListItem.find(@params[:id])
  end
end
