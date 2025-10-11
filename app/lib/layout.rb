class Layout
  def initialize(menu, active_key, nav_resource = nil, **options)
    @menu = menu
    @active_key = active_key
    @nav_resource = nav_resource
    @formatter = options.fetch(:formatter, nil)
  end

  def menu
    BuildNavItemCollectionService.call(menu_data, @active_key, formatter: @formatter)
  end

  private

  def menu_data
    return MenuData.public_send(@menu) unless @nav_resource
    
    MenuData.public_send(@menu, @nav_resource)
  end
end
