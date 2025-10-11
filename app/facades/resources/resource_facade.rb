class Resources::ResourceFacade
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def attachment
    @resource.attachment
  end

  def description
    @resource.description
  end

  def name
    @resource.name
  end

  def row_id
    ["resource", @resource.id].join("_")
  end

  def id
    @resource.id
  end
end
