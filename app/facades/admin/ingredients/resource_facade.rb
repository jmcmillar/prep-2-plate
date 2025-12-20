class Admin::Ingredients::ResourceFacade
  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Name"),
      Table::DefaultHeaderComponent.new("Packaging"),
      Table::DefaultHeaderComponent.new("Preparation"),
      Table::DefaultHeaderComponent.new("Category")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [facade.name, facade.packaging_form, facade.preparation_style, facade.category, facade.action],
      id: facade.id
    )
  end

  def name
    Table::DataComponent.new(@resource.name)
  end

  def packaging_form
    Table::DataComponent.new(@resource.packaging_form&.titleize)
  end

  def preparation_style
    Table::DataComponent.new(@resource.preparation_style&.titleize)
  end

  def category
    Table::DataComponent.new(@resource.ingredient_category_name || "Uncategorized")
  end

  def id
    ["ingredient", @resource.id].join("_")
  end

  def action
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.name, id: @resource.id, controller_path: "admin/ingredients"]
    ]
  end
end
