class ShoppingListItems::EditFacade < BaseFacade
  def shopping_list_item
    @shopping_list_item ||= ShoppingListItem.joins(:shopping_list)
      .where(shopping_lists: { user_id: @user.id })
      .find(@params[:id])
  end

  def shopping_list
    shopping_list_item.shopping_list
  end

  def form_url
    {
      controller: "shopping_list_items",
      id: shopping_list_item.id,
      action: "update"
    }
  end

  def cancel_path
    {
      controller: "shopping_list_items",
      shopping_list_id: shopping_list.id,
      action: "index"
    }
  end
end
