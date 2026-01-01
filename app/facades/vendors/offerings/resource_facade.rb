class Vendors::Offerings::ResourceFacade
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def image
    @resource.image
  end

  def name
    @resource.name
  end

  def offering_price_points
    @resource.offering_price_points
  end

  def vendor_name
    @resource.vendor.business_name
  end
end
