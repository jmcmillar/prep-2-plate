class ShoppingLists::NewFacade < BaseFacade
  def shopping_list
    @shopping_list ||= @user.shopping_lists.new
  end

  def form_url
    {
      controller: "shopping_lists",
      action: "create"
    }
  end

  def cancel_path
    {
      controller: "shopping_lists",
      action: "index"
    }
  end
end
