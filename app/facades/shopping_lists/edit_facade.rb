class ShoppingLists::EditFacade < BaseFacade
  def shopping_list
    @shopping_list ||= @user.shopping_lists.find(@params[:id])
  end

  def set_others_false
    @user.shopping_lists.excluding(shopping_list).update_all(current: false)
  end
end
