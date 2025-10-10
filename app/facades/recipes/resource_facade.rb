class Recipes::ResourceFacade
  attr_reader :resource
  def initialize(resource)
    @resource = resource
  end

  def image
    @resource.image
  end

  def description
    @resource.description
  end

  def name
    @resource.name
  end

  def meal_types
    @resource.meal_types.pluck(:name)
  end

  def recipe_categories
    @resource.recipe_categories.pluck(:name)
  end

  def row_id
    ["recipe", @resource.id].join("_")
  end

  def id
    @resource.id
  end
end
