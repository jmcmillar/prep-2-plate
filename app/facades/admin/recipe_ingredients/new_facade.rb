class Admin::RecipeIngredients::NewFacade < Base::Admin::NewFacade
  def recipe_ingredient
    @ingredient ||= recipe.recipe_ingredients.new
  end

  def strong_params
    return @processed_strong_params if @processed_strong_params

    quantity = @strong_params[:quantity]
    rational = QuantityFactory.new(quantity).create
    @processed_strong_params = {
      numerator: rational.numerator,
      denominator: rational.denominator,
      **@strong_params.except(:quantity)
    }
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
