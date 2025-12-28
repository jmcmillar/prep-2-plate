class UserIngredientPreferences::IndexFacade < BaseFacade
  def base_collection
    @user.user_ingredient_preferences
         .includes(:ingredient)
         .order(last_used_at: :desc)
  end

  def headers
    resource_facade_class.headers
  end

  def rows
    collection.to_a.map { |facade| resource_facade_class.to_row(facade) }
  end

  def header_actions
    [new_action_data]
  end

  def new_action_data
    IconLinkComponent::Data[
      {controller: "user_ingredient_preferences", action: "new"},
      :plus,
      "New Preference"
    ]
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def pagy
    collection.pagy
  end

  def resource_facade_class
    UserIngredientPreferences::ResourceFacade
  end

  def active_key
    :none
  end
end
