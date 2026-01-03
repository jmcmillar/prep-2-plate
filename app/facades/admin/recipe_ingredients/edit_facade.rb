class Admin::RecipeIngredients::EditFacade < Base::Admin::EditFacade
  def recipe_ingredient
    @recipe_ingredient ||= RecipeIngredient.find(@params[:id])
  end

  def strong_params
    quantity = @strong_params.delete(:quantity)
    rational = QuantityFactory.new(quantity).create
    {
      numerator: rational.numerator,
      denominator: rational.denominator,
      **@strong_params
    }
  end

  def recipe
    recipe_ingredient.recipe
  end

  def active_key
    :admin_recipes
  end

  def measurement_units
    @measurement_units ||= MeasurementUnit.order(:name)
  end

  def ingredients
    @ingredients ||= Ingredient::DisplayNameDecorator.decorate_collection(Ingredient.order(:name))
  end

  def ingredient_options
    ingredients.map do |ing|
      [ing.display_name, ing.id, {
        'data-packaging-form' => ing.packaging_form,
        'data-preparation-style' => ing.preparation_style
      }]
    end
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Ingredients", [:admin, :recipe_ingredients]),
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, recipe_ingredient]
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
