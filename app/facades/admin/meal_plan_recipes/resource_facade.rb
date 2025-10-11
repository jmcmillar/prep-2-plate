class Admin::MealPlanRecipes::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Recipe"),
      Table::DefaultHeaderComponent.new("Date"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.recipe_name, facade.date, facade.action],
      id: facade.id
    )
  end

  def date
    Table::DataComponent.new(@resource.date)
  end

  def recipe_name
    Table::DataComponent.new(@resource.recipe.name)
  end

  def id
    ["meal_plan_recipe", @resource.id].join("_")
  end

  def action
    Table::IconActionsComponent.new(actions)
  end

  def actions
    Link::RowActions.to_data(
    id: @resource.id,
    label: @resource.recipe_name,
    controller: "admin/meal_plan_recipes"
    )
  end
end
