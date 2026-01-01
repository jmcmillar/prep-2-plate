class Admin::Offerings::EditFacade < Base::Admin::EditFacade
  def offering
    @offering ||= Offering.find(@params[:id])
  end

  def active_key
    :admin_offerings
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :vendors]),
      BreadcrumbComponent::Data.new("Vendors", [:admin, :vendors]),
      BreadcrumbComponent::Data.new(offering.vendor.business_name, [:admin, offering.vendor]),
      BreadcrumbComponent::Data.new("Offerings", [:admin, offering.vendor, :offerings]),
      BreadcrumbComponent::Data.new(offering.name, [:admin, offering]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, offering]
  end

  def meal_types
    @meal_types ||= Rails.cache.fetch("meal_types_ordered", expires_in: 12.hours) do
      MealType.order(:name).to_a
    end
  end

  def ingredients
    @ingredients ||= Rails.cache.fetch("ingredients_ordered", expires_in: 12.hours) do
      Ingredient.order(:name).to_a
    end
  end

  def ingredient_options
    decorated_ingredients.map do |ing|
      [ing.ingredient_name_with_details, ing.id]
    end
  end

  def decorated_ingredients
    @decorated_ingredients ||= IngredientFullNameDecorator.decorate_collection(ingredients)
  end

  def measurement_units
    @measurement_units ||= Rails.cache.fetch("measurement_units_ordered", expires_in: 12.hours) do
      MeasurementUnit.order(:name).to_a
    end
  end

  def packaging_form_options
    Ingredient::PACKAGING_FORMS.keys.map { |form| [form.to_s.titleize, form] }
  end

  def preparation_style_options
    Ingredient::PREPARATION_STYLES.keys.map { |style| [style.to_s.titleize, style] }
  end

  def default_serving_sizes
    [2, 4, 6, 8, 10]
  end

  def menu
    :admin_vendor_menu
  end

  def nav_resource
    offering.vendor
  end

  def active_key
    :admin_offerings
  end
end
