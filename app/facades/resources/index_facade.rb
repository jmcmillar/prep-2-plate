class Resources::IndexFacade < BaseFacade
  def base_collection
    Resource.order(:name).with_attached_attachment
  end

  def collection
    CollectionBuilder.new(base_collection, self)
  end

  def search_data
    SearchFormComponent::Data[
      form_url: [:resources],
      query: collection.search_collection,
      label: "Search Name",
      field: :name_cont
    ]
  end

  def search_fields
    :name_cont
  end

  def search_label
    'Search Resources'
  end

  def resource_facade_class
    Resources::ResourceFacade
  end

  def active_key
    :resources
  end
end
