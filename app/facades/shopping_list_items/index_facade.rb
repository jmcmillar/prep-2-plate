class ShoppingListItems::IndexFacade < BaseFacade
  def base_collection
    shopping_list.shopping_list_items.order(:name)
  end

  def headers
    resource_facade_class.headers
  end

  def rows
    collection.to_a.map { |facade| resource_facade_class.to_row(facade) }
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def header_actions
    [new_action_data]
  end

  def new_action_data
    IconLinkComponent::Data[
      [:new, shopping_list, :item],
      :plus, 
      "New Item",
    ]
  end

  def pagy
    collection.pagy
  end

  def resource_facade_class
    ShoppingListItems::ResourceFacade
  end

  def active_key
    :none
  end

  def shopping_list
    @user.shopping_lists.find(@params[:shopping_list_id])
  end
end
