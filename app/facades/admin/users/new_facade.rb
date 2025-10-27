class Admin::Users::NewFacade < Base::Admin::NewFacade
  def resource
    @resource ||= User.new.tap do |user|
      user.password = SecureRandom.hex(12)
    end
  end

  def active_key
    :admin_users
  end

    def form_url
    {
      controller: "admin/users",
      action: "create"
    }
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Users", [:admin, :users]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
