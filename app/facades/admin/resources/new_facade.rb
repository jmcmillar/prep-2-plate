class Admin::Resources::NewFacade < Base::Admin::NewFacade
  def resource
    @resource ||= Resource.new
  end

  def active_key
    :admin_resources
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Resources", [:admin, :resources]),
      BreadcrumbComponent::Data.new("New")
    ]
  end
end
