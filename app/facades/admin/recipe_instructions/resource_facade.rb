class Admin::RecipeInstructions::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Step Number"),
      Table::DefaultHeaderComponent.new("Instruction"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.step_number,
        facade.instruction,
        facade.action
      ],
      id: facade.id
    )
  end

  def step_number
    Table::DataComponent.new(@resource.step_number)
  end

  def instruction
    Table::DataComponent.new(@resource.instruction)
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def id
    ["recipe_instruction", @resource.id].join("_")
  end

  private

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.step_number, id: @resource.id, controller_path: "admin/recipe_instructions"]
    ]
  end
end
