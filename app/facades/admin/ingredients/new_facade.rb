class Admin::Ingredients::NewFacade < Base::Admin::NewFacade
  def ingredient
    @ingredient ||= Ingredient.new
  end

  def active_key
    :admin_ingredients
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredients", [:admin, :ingredients]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def form_url
    [:admin, ingredient]
  end

  def cancel_path
    [:admin, :ingredients]
  end

  def ingredient_categories
    IngredientCategory.order(:name)
  end

  def packaging_form_options
    Ingredient::PACKAGING_FORMS.map { |key, value| [value, key.to_s] }
  end

  def preparation_style_options
    Ingredient::PREPARATION_STYLES.map { |key, value| [value, key.to_s] }
  end
end
