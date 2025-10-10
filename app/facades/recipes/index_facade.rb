class Recipes::IndexFacade < BaseFacade
  def base_collection
    Recipe.order(:name)
      .includes(:user_recipe)
      .with_attached_image
      .where(user_recipes: { user_id: [@user&.id, nil] })
      .filtered_by_meal_types(@params[:meal_type_ids])
      .filtered_by_recipe_categories(@params[:recipe_category_ids])
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:recipes],
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
      "New Recipe",
      [:new, :user_recipe],
      :plus,
      :primary,
      { data: { turbo: false}}
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
