class ShoppingListItems::NewFacade < BaseFacade
  def shopping_list_item
    @shopping_list_item ||= shopping_list.shopping_list_items.new(name: @params[:name])
  end
  
  def shopping_list
    @user.shopping_lists.find(@params[:shopping_list_id])
  end
end
