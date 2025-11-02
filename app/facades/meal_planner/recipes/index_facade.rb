class MealPlanner::Recipes::IndexFacade < BaseFacade
  def collection
    CollectionBuilder.new(base_collection, self)
  end
  
  def base_collection
    @recipes ||= Recipe
      .includes(:user_recipe)
      .with_attached_image
      .where(user_recipes: { user_id: [@user&.id, nil] })
      .filtered_by_meal_types(@params[:meal_type_ids])
      .filtered_by_recipe_categories(@params[:recipe_category_ids])
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
      MealType.all.order(:name),
      false
    )
  end

  def recipe_category_filter_data
    FilterComponent::Data.new(
      'Recipe Categories',
      "recipe_category_ids[]",
      RecipeCategory.all.order(:name),
      false
    )
  end

  def resource_facade_class
    Recipes::ResourceFacade
  end

  def active_key
    :meal_plans
  end

  def pagy_limit
    @pagy_limit ||= 20
  end
end
