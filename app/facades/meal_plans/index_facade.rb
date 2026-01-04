class MealPlans::IndexFacade < BaseFacade
  def base_collection
    MealPlan.order(:name).non_user_associated
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:meal_plans],
      query: collection.search_collection,
      label: "Search By Name",
      field: :name_cont
    ]
  end

  def resource_facade_class
    MealPlans::ResourceFacade
  end

  def active_key
    :meal_plans
  end
end
