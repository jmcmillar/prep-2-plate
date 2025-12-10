class Admin::Users::ShowFacade < Base::Admin::ShowFacade
  def resource
    @resource ||= User.find(@params[:id])
  end

  def active_key
    :admin_user
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    resource
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :users]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new(resource.email)
    ]
  end

  def edit_action_data
    IconLinkComponent::Data[
      [:edit, :admin, resource],
      :edit, 
      "User",
    ]
  end
end
