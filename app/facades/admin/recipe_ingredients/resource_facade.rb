class Admin::RecipeIngredients::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Quantity"),
      Table::DefaultHeaderComponent.new("Unit"),
      Table::DefaultHeaderComponent.new("Ingredient"),
      Table::DefaultHeaderComponent.new("Packaging"),
      Table::DefaultHeaderComponent.new("Preparation"),
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
        facade.packaging_form,
        facade.preparation_style,
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

  def packaging_form
    Table::DataComponent.new(@resource.ingredient_packaging_form&.titleize)
  end

  def preparation_style
    Table::DataComponent.new(@resource.ingredient_preparation_style&.titleize)
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
