class Admin::ShoppingLists::DestroyFacade < Base::Admin::DestroyFacade
  def shopping_list
    @shopping_list ||= ShoppingList.find(@params[:id])
  end
end
