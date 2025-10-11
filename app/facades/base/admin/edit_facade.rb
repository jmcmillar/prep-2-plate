class Base::Admin::EditFacade < BaseFacade
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
    @user.admin?
  end
end
