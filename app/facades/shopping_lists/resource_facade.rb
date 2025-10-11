class ShoppingLists::ResourceFacade
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name"),
      Table::DefaultHeaderComponent.new("Items"),
      Table::DefaultHeaderComponent.new("Last Updated"),
      Table::DefaultHeaderComponent.new("Favorite"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.name, facade.item_count, facade.last_updated_at, facade.toggle_form, facade.action],
      id: facade.id
    )
  end

  def id
    ["shopping_list", @resource.id].join("_")
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def last_updated_at
    Table::DataComponent.new(@resource.updated_at.strftime("%d %b %Y"))
  end

  def item_count
    Table::DataComponent.new(@resource.shopping_list_items.count)
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.name, id: @resource.id, controller_path: "shopping_lists"]
    ]
  end

  def toggle_form
    ToggleFormComponent.new(toggle_data)
  end


  def toggle_data
    ToggleFormComponent::Data[
      [@resource, { current: true}],
      :patch,
      "Toggle Current",
      icon_data
    ]
  end

  def icon_data
    resource.current? ? active_icon_data : inactive_icon_data
  end

  def active_icon_data
    IconComponent::Data.new(:star, :fas, class: "text-secondary")
  end

  def inactive_icon_data
    IconComponent::Data.new(:star, :fal, class: "text-gray-400")
  end
end
