class Recipes::ShowFacade < BaseFacade
  SERVING_SIZES = [2, 4, 6, 8, 10]
  def resource
    Recipe.find @params[:id]
  end

  def level
    resource.difficulty_level&.titleize || "Not specified"
  end

  def meal_types
    resource.meal_types.order(:name).pluck(:name)
  end

  def recipe_categories
    resource.recipe_categories.order(:name).pluck(:name)
  end

  def duration
    return "Not specified" if resource.duration_minutes.nil?
    "#{resource.duration_minutes} minutes"
  end

  def yield
    return "Not specified" if resource.serving_size.nil?
    "#{resource.serving_size} #{"serving".pluralize(resource.serving_size)}"
  end

  def description
    resource.description
  end

  def serving_size_collection
    SERVING_SIZES.map { |size| [size, size] }
  end

  def current_size
    @params[:serving_size]&.to_i || resource.serving_size || 2
  end

  def ingredients
    QuantityMultiplierDecorator.decorate_collection(recipe_ingredients, current_size).then { |collection|
      RecipeIngredient::FullNameDecorator.decorate_collection(collection)
    }
  end

  def recipe_ingredients
    @recipe_ingredients ||= resource.recipe_ingredients.includes(:measurement_unit, :ingredient)
  end

  def instructions
    resource.recipe_instructions.order(:step_number)
  end

  def active_key
    :recipes
  end
end
