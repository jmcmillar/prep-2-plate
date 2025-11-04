class MyRecipes::IndexFacade < BaseFacade
  def base_collection
    Recipe.order(:name)
      .joins(:user_recipe)
      .with_attached_image
      .where(user_recipe: { user_id: @user.id })
      .filtered_by_meal_types(@params[:meal_type_ids])
      .filtered_by_recipe_categories(@params[:recipe_category_ids])
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def favorites
    CollectionBuilder.new(favorite_collection, self)
  end

  def favorite_collection
    @user.recipes.order(:name)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:my_recipes],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :name_cont
    ]
  end

  def meal_type_filter_data
    FilterComponent::Data.new(
      'Meal Types',
      "meal_type_ids[]",
      MealType.all.order(:name)
    )
  end

  def recipe_category_filter_data
    FilterComponent::Data.new(
      'Recipe Categories',
      "recipe_category_ids[]",
      RecipeCategory.all.order(:name)
    )
  end

  def search_fields
    :name_cont
  end

  def search_label
    'Search Recipes'
  end

  def new_user_recipe_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "",
      [:new, :user_recipe],
      :plus,
      :primary,
      { data: { turbo: false}}
    ]
  end

  def import_button_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "",
      {controller: "user_recipe_imports", action: "new"},
      :file_import,
      :primary,
      { data: { turbo: false } }
    ]
  end

  def resource_facade_class
    Recipes::ResourceFacade
  end

  def active_key
    :recipes
  end

  def pagy
    collection.pagy
  end

  def pagy_limit
    @pagy_limit ||= 6
  end
end
