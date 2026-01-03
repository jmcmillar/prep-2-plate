class UserRecipes::NewFacade < BaseFacade
  DifficultyLevel = Struct.new(:name, :value)
  def user_recipe
    @user_recipe ||= @user.user_recipes.new.tap do |ur|
      ur.build_recipe.tap do |recipe|
      end
    end
  end

  def form_url
    [ user_recipe ]
  end

  def difficulty_levels
    Recipe.difficulty_levels.map do |level|
      DifficultyLevel[*level]
    end
  end

  def categories
    @categories ||= Rails.cache.fetch("recipe_categories_ordered", expires_in: 12.hours) do
      RecipeCategory.order(:name).to_a
    end
  end

  def meal_types
    @meal_types ||= Rails.cache.fetch("meal_types_ordered", expires_in: 12.hours) do
      MealType.order(:name).to_a
    end
  end

  def ingredients
    @ingredients ||= Ingredient::DisplayNameDecorator.decorate_collection(
      Rails.cache.fetch("ingredients_ordered", expires_in: 12.hours) do
        Ingredient.order(:name).to_a
      end
    )
  end

  def measurement_units
    @measurement_units ||= Rails.cache.fetch("measurement_units_ordered", expires_in: 12.hours) do
      MeasurementUnit.order(:name).to_a
    end
  end

  def new_user_recipe_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "New Recipe",
      [ :new, :user_recipe ],
      :plus,
      :primary,
      { data: { turbo: false } }
    ]
  end

  def packaging_form_options
    Ingredient::PACKAGING_FORMS.map { |key, value| [value, key.to_s] }
  end

  def preparation_style_options
    Ingredient::PREPARATION_STYLES.map { |key, value| [value, key.to_s] }
  end

  def ingredient_options
    ingredients.map do |ing|
      [ing.display_name, ing.id, {
        'data-packaging-form' => ing.packaging_form,
        'data-preparation-style' => ing.preparation_style
      }]
    end
  end
end
