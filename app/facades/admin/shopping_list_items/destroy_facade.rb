class Admin::ShoppingListItems::DestroyFacade < Base::Admin::DestroyFacade
  def shopping_list_item
    @shopping_list_item ||= ShoppingListItem.unscoped.find(@params[:id])
  end

  # Archive instead of destroy
  def archive
    ShoppingListItems::Archive.call(shopping_list_item)
  end
end
