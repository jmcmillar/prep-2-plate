class BaseDecorator < SimpleDelegator
  def initialize(object, *args)
    @object = object
    super(@object)
  end

  def self.decorate(object, *args)
    new(object, *args)
  end

  def self.decorate_collection(collection, *args)
    collection.map { |object| new(object, *args) }
  end

  def original_object
    @object
  end

  def source_object
    @object.respond_to?(:source_object) ? @object.source_object : @object
  end
end

