class Admin::MealPlanIngredients::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.name],
      id: facade.id
    )
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def id
    ["meal_plan_ingredient", @resource.id].join("_")
  end
end
