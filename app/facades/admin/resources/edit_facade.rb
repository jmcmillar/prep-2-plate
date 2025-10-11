class Admin::Resources::EditFacade < Base::Admin::EditFacade
  def resource
    @resource ||= Resource.find(@params[:id])
  end

  def active_key
    :admin_resources
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Resources", [:admin, :resources]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end
end
