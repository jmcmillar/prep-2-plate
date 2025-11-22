class Recipes::ShowFacade < BaseFacade
  SERVING_SIZES = [ 2, 4, 6, 8, 10 ]
  def resource
    @resource ||= Recipe
      .includes(
        :user_recipe,
        :meal_types,
        :recipe_categories,
        :recipe_instructions,
        recipe_ingredients: [ :measurement_unit, :ingredient ]
      )
      .where(user_recipe: { user_id: [ nil, @user&.id ] })
      .find(@params[:id])
  end

    def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Recipes", [ :recipes ]),
      BreadcrumbComponent::Data.new(resource.name)
    ]
  end

  def level
    resource.difficulty_level&.titleize || "Not specified"
  end

  def recipe_favorite_toggle_data
    return ToggleFormComponent::Data.new unless @user.present? && !resource.user_recipe

    if @user.recipes.exists?(resource.id)
      destroy_favorite_toggle_data
    else
      create_favorite_toggle_data
    end
  end

  def create_favorite_toggle_data
    ToggleFormComponent::Data.new(
      { controller: "recipe_favorites", action: "create", recipe_id: resource.id },
      :post,
      "Add to Favorites",
      IconComponent::Data.new(:heart, :fal, class: "text-red-500 text-2xl")
    )
  end

  def destroy_favorite_toggle_data
    ToggleFormComponent::Data.new(
      { controller: "recipe_favorites", action: "destroy", id: RecipeFavorite.find_by(user: @user, recipe: resource).id },
      :delete,
      "Remove from Favorites",
      IconComponent::Data.new(:heart, :fas, class: "text-red-500 text-2xl")
    )
  end

  def edit_button_link_data
    return ButtonLinkComponent::Data.new unless resource.user_recipe && resource.user_recipe&.user == @user
    ButtonLinkComponent::Data[
      "",
      { controller: "user_recipes", action: "edit", id: resource.user_recipe&.id },
      :edit,
      :primary,
      { data: { turbo: false } }
    ]
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
    SERVING_SIZES.map { |size| [ size, size ] }
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
    @recipe_ingredients ||= resource.recipe_ingredients
  end

  def instructions
    resource.recipe_instructions.order(:step_number)
  end

  def active_key
    :recipes
  end
end
