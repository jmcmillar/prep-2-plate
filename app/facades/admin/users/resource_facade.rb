class Admin::Users::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [Table::DefaultHeaderComponent.new("Email"), Table::DefaultHeaderComponent.new("Admin?")]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.email, facade.admin, facade.action],
      id: facade.id
    )
  end

  def email
    Table::DataComponent.new(@resource.email)
  end

  def admin
    Table::DataComponent.new(@resource.admin? ? "Yes" : "No")
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
