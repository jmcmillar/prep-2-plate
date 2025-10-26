class ShoppingListItems::DestroyFacade < BaseFacade
  def shopping_list_item
    @shopping_list_item ||= ShoppingListItem.joins(:shopping_list)
      .where(shopping_lists: { user_id: @user.id })
      .find(@params[:id])
  end

  def shopping_list
    shopping_list_item.shopping_list
  end
end
