class Admin::ShoppingLists::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_shopping_lists
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    shopping_list_user
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, shopping_list_user.shopping_lists.order(:name)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping Lists")
    ]
  end

  def shopping_list_user
    @shopping_list_user ||= User.find(@params[:user_id])
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, shopping_list_user, :shopping_list],
      :plus, 
      "New Shopping List",
      target: "_top"
    ]
  end

  def resource_facade_class
    Admin::ShoppingLists::ResourceFacade
  end
end
