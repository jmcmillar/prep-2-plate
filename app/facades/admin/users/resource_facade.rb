class Admin::Users::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("First Name"),
      Table::DefaultHeaderComponent.new("Last Name"),
      Table::DefaultHeaderComponent.new("Email"),
      Table::DefaultHeaderComponent.new("Admin?"),
      Table::DefaultHeaderComponent.new("Deactivated?")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.first_name, facade.last_name, facade.email, facade.admin, facade.deactivated, facade.action],
      id: facade.id
    )
  end

  def first_name
    Table::DataComponent.new(@resource.first_name)
  end

  def last_name
    Table::DataComponent.new(@resource.last_name)
  end

  def email
    Table::DataComponent.new(@resource.email)
  end

  def admin
    Table::DataComponent.new(@resource.admin? ? "Yes" : "No")
  end

  def deactivated
    Table::DataComponent.new(@resource.deactivated? ? "Yes" : "No")
  end

  def id
    ["user", @resource.id].join("_")
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.email, id: @resource.id, controller_path: "admin/users"]
    ]
  end
end
