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

  def resource_facade_class
    Recipes::ResourceFacade
  end

  def active_key
    :meal_plans
  end


  def new_user_recipe_link_data
    return ButtonLinkComponent::Data.new unless @user.present?
    ButtonLinkComponent::Data[
      "",
      [:new, :user_recipe],
      :plus,
      :primary,
      { class: "text-sm py-3 px-2", data: { turbo: false}}
    ]
  end

  def pagy_limit
    @pagy_limit ||= 20
  end
end
