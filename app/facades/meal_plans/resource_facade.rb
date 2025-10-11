class MealPlans::ResourceFacade
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def name
    @resource.name
  end

  def description
    @resource.description
  end

  def duration
    "7 days"
  end
end
