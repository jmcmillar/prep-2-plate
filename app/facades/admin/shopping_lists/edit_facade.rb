class Admin::ShoppingLists::EditFacade < Base::Admin::DestroyFacade
  def shopping_list
    @shopping_list ||= ShoppingList.find(@params[:id])
  end

  def active_key
    :admin_shopping_lists
  end

  def menu
    :admin_user_menu
  end

  def form_url
    [:admin, shopping_list]
  end

  def nav_resource
    shopping_list.user
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping Lists", [:admin, :shopping_lists]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
