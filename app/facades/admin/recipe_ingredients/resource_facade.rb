class Admin::RecipeIngredients::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Quantity"),
      Table::DefaultHeaderComponent.new("Unit"),
      Table::DefaultHeaderComponent.new("Ingredient Name"),
      Table::DefaultHeaderComponent.new("Notes"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.quantity,
        facade.measurement_unit_name,
        facade.ingredient_name,
        facade.notes,
        facade.action
      ],
      id: facade.id
    )
  end

  def quantity
    Table::DataComponent.new(@resource.quantity)
  end

  def measurement_unit_name
    Table::DataComponent.new(@resource.measurement_unit_name)
  end

  def ingredient_name
    Table::DataComponent.new(@resource.ingredient_name)
  end

  def notes
    Table::DataComponent.new(@resource.notes)
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def id
    ["recipe_ingredient", @resource.id].join("_")
  end

  private

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.ingredient.name, id: @resource.id, controller_path: "admin/recipe_ingredients"]
    ]
  end
end
