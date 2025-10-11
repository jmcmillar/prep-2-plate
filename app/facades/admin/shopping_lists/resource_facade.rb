class Admin::ShoppingLists::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [Table::DefaultHeaderComponent.new("Name")]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.name, facade.action],
      id: facade.id
    )
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def id
    ["shopping_list", @resource.id].join("_")
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.name, id: @resource.id, controller_path: "admin/shopping_lists"]
    ]
  end
end
