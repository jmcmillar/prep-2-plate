class ShoppingListItems::ResourceFacade
  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.name, facade.action],
      id: facade.id
    )
  end

  def id
    ["shopping_list_item", @resource.id].join("_")
  end

  def name
    Table::DataComponent.new(@resource.display_name)
  end


  def action
    Table::IconActionsComponent.new(actions)
  end

  def actions
    Link::RowActions.to_data(
      id: @resource.id,
      label: @resource.name,
      controller: "shopping_list_items"
    )
  end
end
