class Base::Admin::ShowFacade < BaseFacade
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
    :admin_recipes
  end

  def authorized?
    Base::AdminPolicy.new(@user, nil).show?
  end


  def header_actions
    [edit_action_data]
  end

  def edit_action_data
  end
end
