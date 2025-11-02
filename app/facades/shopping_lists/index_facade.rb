class ShoppingLists::IndexFacade < BaseFacade
  def base_collection
    @user.shopping_lists.order(:name)
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
      {controller: "shopping_lists", action: "new"},
      :plus, 
      "New Shopping List",
    ]
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def pagy
    collection.pagy
  end

  def resource_facade_class
    ShoppingLists::ResourceFacade
  end

  def active_key
    :none
  end
end
