class Base::Admin::IndexFacade < BaseFacade
  attr_reader :pagy_limit
  def initialize(...)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  def layout
    Layout.new(menu, active_key, nav_resource)
  end

  def menu
    :admin_menu
  end

  def nav_resource
  end

  def active_key
  end

  def headers
    resource_facade_class.headers
  end

  def rows
    collection.to_a.map { |facade| resource_facade_class.to_row(facade) }
  end

  def pagy
    collection.pagy
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def header_actions
    [new_action_data]
  end

  def new_action_data
  end

  def authorized?
    Base::AdminPolicy.new(@user, nil).index?
  end

  def pagy_limit
    @pagy_limit ||= 25
  end
end
