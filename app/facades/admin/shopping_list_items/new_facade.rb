class Admin::ShoppingListItems::NewFacade < Base::Admin::NewFacade
  def shopping_list_item
    @shopping_list_item ||= shopping_list.shopping_list_items.new
  end

  def active_key
    :admin_shopping_lists
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    shopping_list.user
  end

  def shopping_list
    @shopping_list ||= ShoppingList.find(params[:shopping_list_id])
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping List Items", [:admin, :shopping_list_items]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def form_url
    [:admin, shopping_list, :shopping_list_items]
  end

  def cancel_path
    [:admin, shopping_list, :shopping_list_items]
  end
end
