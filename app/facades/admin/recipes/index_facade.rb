class Admin::Recipes::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_recipes
  end
  
  def base_collection
    Base::AdminPolicy::Scope.new(
      @user,
      Recipe.order(:name)
        .where.missing(:user_recipe)
        .filtered_by_meal_types(@params[:meal_type_ids])
        .filtered_by_recipe_categories(@params[:recipe_category_ids])
    ).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipes")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :recipes],
      query: collection.search_collection,
      label: "Search Name, Meal Types, Categories",
      field: :name_cont
    ]
  end

  def header_actions
    [import_action_data, new_action_data]
  end

  def import_action_data
    IconLinkComponent::Data[
      [:new, :admin, :recipe_import],
      :file_import, 
      "Import New Recipe",
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :recipe],
      :plus, 
      "New Recipe",
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

  def resource_facade_class
    Admin::Recipes::ResourceFacade
  end
end
