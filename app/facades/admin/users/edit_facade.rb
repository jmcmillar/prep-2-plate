class Admin::Users::EditFacade < Base::Admin::EditFacade
  def user
    @user ||= User.find(@params[:id])
  end

  def active_key
    :admin_users
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
