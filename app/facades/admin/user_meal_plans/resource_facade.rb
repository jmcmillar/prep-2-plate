class Admin::UserMealPlans::ResourceFacade
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
    Table::DataComponent.new(@resource.meal_plan.name)
  end

  def id
    ["user_meal_plan", @resource.id].join("_")
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.meal_plan.name, id: @resource.id, controller_path: "admin/user_meal_plans"]
    ]
  end
end
