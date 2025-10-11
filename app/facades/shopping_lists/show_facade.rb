class ShoppingLists::ShowFacade < BaseFacade
  def resource
    @user.shopping_lists.find(@params[:id])
  end

  def shopping_list_items
    resource.shopping_list_items
  end

  def name
    resource.name
  end
end
