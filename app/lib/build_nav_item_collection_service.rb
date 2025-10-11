class BuildNavItemCollectionService
  def initialize(menu_items, active_key, **options)
    @menu_items = menu_items
    @active_key = active_key
    @formatter = options[:formatter] || MenuData::Format.admin_main_menu
  end

  def self.call(...)
    new(...).call
  end

  def call
    @menu_items.map { |menu_item| build_nav_item_data(menu_item) }.compact
  end

  private

  def build_nav_item_data(menu_item)
    return unless menu_item.allowed
    
    NavItemComponent::Data[
      menu_item.title,
      menu_item.path,
      set_format(menu_item),
      set_icon(menu_item)
    ]
  end

  def set_format(menu_item)
    return @formatter.default unless menu_item.key.eql? @active_key

    @formatter.active
  end

  def set_icon(menu_item)
    MenuData::IconMap.to_h[menu_item.key]
  end

end
