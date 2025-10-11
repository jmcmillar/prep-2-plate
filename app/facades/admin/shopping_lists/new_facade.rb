class Admin::ShoppingLists::NewFacade < Base::Admin::NewFacade
  def shopping_list
    @shopping_list ||= shopping_list_user.shopping_lists.new
  end

  def active_key
    :admin_shopping_lists
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    shopping_list_user
  end

  def form_url
    [:admin, shopping_list_user, :shopping_lists]
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping Lists", [:admin, :shopping_lists]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def shopping_list_user
    @shopping_list_user ||= User.find(@params[:user_id])
  end
end
