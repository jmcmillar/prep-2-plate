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
