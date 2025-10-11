class Admin::Users::NewFacade < Base::Admin::NewFacade
  def user
    @user ||= User.new
  end

  def active_key
    :admin_users
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
