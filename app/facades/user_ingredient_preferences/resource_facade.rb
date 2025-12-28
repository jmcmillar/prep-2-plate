class UserIngredientPreferences::ResourceFacade
  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end

  def self.headers
    [
      Table::DefaultHeaderComponent.new("Ingredient"),
      Table::DefaultHeaderComponent.new("Packaging"),
      Table::DefaultHeaderComponent.new("Preparation"),
      Table::DefaultHeaderComponent.new("Preferred Brand"),
      Table::DefaultHeaderComponent.new("Usage Count"),
      Table::DefaultHeaderComponent.new("Last Used"),
      Table::DefaultHeaderComponent.new("")
    ]
  end

  def self.to_row(facade)
    Table::RowComponent.new(
      [
        facade.ingredient_name,
        facade.packaging_form_display,
        facade.preparation_style_display,
        facade.preferred_brand,
        facade.usage_count,
        facade.last_used_at,
        facade.actions
      ],
      id: facade.id
    )
  end

  def id
    ["user_ingredient_preference", @resource.id].join("_")
  end

  def ingredient_name
    Table::DataComponent.new(@resource.display_context)
  end

  def packaging_form_display
    if @resource.packaging_form.present?
      display_value = Ingredient::PACKAGING_FORMS[@resource.packaging_form.to_sym]
      Table::DataComponent.new(display_value)
    else
      Table::DataComponent.new("Any")
    end
  end

  def preparation_style_display
    if @resource.preparation_style.present?
      display_value = Ingredient::PREPARATION_STYLES[@resource.preparation_style.to_sym]
      Table::DataComponent.new(display_value)
    else
      Table::DataComponent.new("Any")
    end
  end

  def preferred_brand
    Table::DataComponent.new(@resource.preferred_brand)
  end

  def usage_count
    Table::DataComponent.new(@resource.usage_count)
  end

  def last_used_at
    Table::DataComponent.new(@resource.last_used_at.strftime("%d %b %Y"))
  end

  def actions
    Table::ActionComponent.new(action_turbo_data)
  end

  def action_turbo_data
    TurboData[
      :table_actions,
      [:table_actions, label: @resource.display_context, id: @resource.id, controller_path: "user_ingredient_preferences"]
    ]
  end
end
