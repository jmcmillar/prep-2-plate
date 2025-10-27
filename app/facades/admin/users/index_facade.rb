class Admin::Users::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_users
  end

  def base_collection
    Base::AdminPolicy::Scope.new(@user, User.order(:email_address)).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users")
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      {controller: "admin/users", action: "new"},
      :plus, 
      "New User",
      target: "_top"
    ]
  end

  def resource_facade_class
    Admin::Users::ResourceFacade
  end
end


