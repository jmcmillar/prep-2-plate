class Admin::ShoppingListItems::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_shopping_lists
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    shopping_list
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, shopping_list.shopping_list_items.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping Lists", [:admin, :shopping_lists]),
      BreadcrumbComponent::Data.new(shopping_list.name, [:admin, shopping_list]),
      BreadcrumbComponent::Data.new("Items")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, shopping_list, :shopping_list_item],
      :plus, 
      "New Item",
    ]
  end

  def shopping_list
    @shopping_list ||= ShoppingList.find(@params[:shopping_list_id])
  end

  def resource_facade_class
    Admin::ShoppingListItems::ResourceFacade
  end
end
