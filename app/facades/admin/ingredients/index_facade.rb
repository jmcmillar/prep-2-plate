class Admin::Ingredients::IndexFacade < Base::Admin::IndexFacade
  def active_key
    :admin_ingredients
  end

  def base_collection
    Base::AdminPolicy::Scope.new(
      @user,
      Ingredient.order(:name)
        .filtered_by_ingredient_category(@params[:ingredient_category_ids])
    ).resolve
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Ingredients")
    ]
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:admin, :ingredients],
      query: collection.search_collection,
      label: "Search Name",
      field: :name_cont
    ]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, :admin, :ingredient],
      :plus,
      "New Ingredient",
      target: "_top"
    ]
  end

  def ingredient_category_filter_data
    FilterComponent::Data.new(
      "Categories",
      "ingredient_category_ids[]",
      Rails.cache.fetch("ingredient_categories_ordered", expires_in: 12.hours) do
        IngredientCategory.order(:name).to_a
      end
    )
  end

  def resource_facade_class
    Admin::Ingredients::ResourceFacade
  end
end
