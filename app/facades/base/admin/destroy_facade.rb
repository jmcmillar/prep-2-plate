class Base::Admin::DestroyFacade < BaseFacade
  def initialize(...)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  def layout
    Layout.new(menu, active_key, nav_resource)
  end

  def nav_resource
  end

  def menu
    :admin_menu
  end

  def active_key
  end

  def authorized?
    Base::AdminPolicy.new(@user, nil).destroy?
  end

  def breadcrumb_trail
    []
  end

  def header_actions
    []
  end
end
