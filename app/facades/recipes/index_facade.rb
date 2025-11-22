class Recipes::IndexFacade < BaseFacade
  def base_collection
    Recipe.order(:name)
      .includes(:user_recipe)
      .with_attached_image
      .where(user_recipes: { user_id: nil })
      .filtered_by_meal_types(@params[:meal_type_ids])
      .filtered_by_recipe_categories(@params[:recipe_category_ids])
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [ :recipes ],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :name_cont
    ]
  end

  def meal_type_filter_data
    FilterComponent::Data.new(
      "Meal Types",
      "meal_type_ids[]",
      Rails.cache.fetch("meal_types_ordered", expires_in: 12.hours) do
        MealType.order(:name).to_a
      end
    )
  end

  def recipe_category_filter_data
    FilterComponent::Data.new(
      "Recipe Categories",
      "recipe_category_ids[]",
      Rails.cache.fetch("recipe_categories_ordered", expires_in: 12.hours) do
        RecipeCategory.order(:name).to_a
      end
    )
  end

  def search_fields
    :name_cont
  end

  def search_label
    "Search Recipes"
  end

  def my_recipes_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "My Recipes",
      [ :my_recipes ],
      :book,
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
