class Admin::RecipeIngredients::NewFacade < Base::Admin::NewFacade
  def recipe_ingredient
    @ingredient ||= recipe.recipe_ingredients.new
  end

  def strong_params
    rational = QuantityFactory.new(@strong_params.delete(:quantity)).create
    strong_params = {
      numerator: rational.numerator,
      denominator: rational.denominator,
      **@strong_params
    }
    strong_params
  end

  def recipe
    @recipe ||= Recipe.find(@params[:recipe_id])
  end

  def active_key
    :admin_recipes
  end

  def measurement_units
    @measurement_units ||= MeasurementUnit.order(:name)
  end

  def ingredients
    @ingredients ||= Ingredient.order(:name)
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Ingredients", [:admin, :recipe_ingredients]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def form_url
    [:admin, recipe, :recipe_ingredients]
  end

  def cancel_path
    [:admin, recipe, :recipe_ingredients]
  end

  def packaging_form_options
    Ingredient::PACKAGING_FORMS.keys.map { |form| [form.to_s.titleize, form] }
  end

  def preparation_style_options
    Ingredient::PREPARATION_STYLES.keys.map { |style| [style.to_s.titleize, style] }
  end
end
