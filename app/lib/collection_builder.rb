class CollectionBuilder
  def initialize(collection, facade)
    @collection = collection
    @params = facade.params
    @resource_facade_class = facade.resource_facade_class
    @pagy_limit = facade.pagy_limit || 5
  end

  def to_a
    pagy_collection.map { |record| @resource_facade_class.new(record) }
  end

  def pagy_collection
    search_collection.result.offset(pagy.offset).limit(pagy.limit)
  end

  def search_collection
    @search_collection ||= @collection.ransack(@params[:q])
  end

  def pagy
    @pagy ||= Pagy.new(count: search_collection.result.count(:all), page: @params[:page], items: @pagy_limit)
  end
end
