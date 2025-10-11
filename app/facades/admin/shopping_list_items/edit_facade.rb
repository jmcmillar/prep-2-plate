class Admin::ShoppingListItems::EditFacade < Base::Admin::EditFacade
  def shopping_list_item
    @shopping_list_item ||= ShoppingListItem.find(@params[:id])
  end

  def shopping_list
    shopping_list_item.shopping_list
  end

  def active_key
    :admin_shopping_lists
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping List Items", [:admin, :shopping_list_items]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, shopping_list_item]
  end

  def cancel_path
    [:admin, shopping_list_item.shopping_list, :shopping_list_items]
  end
end
