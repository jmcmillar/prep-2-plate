class Admin::ShoppingLists::ShowFacade < Base::Admin::ShowFacade
  def shopping_list
    @shopping_list ||= ShoppingList.find(@params[:id])
  end

  def menu
    :admin_user_menu
  end

  def active_key
    :admin_shopping_lists
  end

  def nav_resource
    shopping_list.user
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping Lists", [:admin, :shopping_lists]),
      BreadcrumbComponent::Data.new(shopping_list.name)
    ]
  end

  def header_actions
    [edit_action_data]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, shopping_list],
      :edit, 
      "Edit Shopping List",
    ]
  end
end
