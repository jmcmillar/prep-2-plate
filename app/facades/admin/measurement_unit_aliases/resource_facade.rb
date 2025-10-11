class Admin::MeasurementUnitAliases::ResourceFacade
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
    ["measurement_unit_alias", @resource.id].join("_")
  end

  def action
    Table::IconActionsComponent.new(actions)
  end

  def actions
    Link::RowActions.to_data(
      id: @resource.id,
      label: @resource.name,
      controller: "admin/measurement_unit_aliases"
    )
  end
end
