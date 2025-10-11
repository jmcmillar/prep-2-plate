class Admin::Recipes::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name"),
      Table::DefaultHeaderComponent.new("Meal Types"),
      Table::DefaultHeaderComponent.new("Categories")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.name,
        facade.types,
        facade.categories,
        facade.action
      ],
      id: facade.id
    )
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def types
    Table::DataComponent.new(meal_types)
  end

  def categories
    Table::DataComponent.new(recipe_categories)
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def id
    ["recipe", @resource.id].join("_")
  end

  private

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.name, id: @resource.id, controller_path: "admin/recipes"]
    ]
  end

  def meal_types
    @resource.meal_types.pluck(:name).join(", ")
  end

  def recipe_categories
    @resource.recipe_categories.pluck(:name).join(", ")
  end
end
