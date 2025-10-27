class Admin::Users::EditFacade < Base::Admin::EditFacade
  def resource
    @resource ||= User.find(@params[:id])
  end

  def active_key
    :admin_users
  end

  def form_url
    {
      controller: "admin/users",
      action: "update",
      id: resource.id
    }
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
