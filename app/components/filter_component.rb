class FilterComponent < ApplicationComponent
  Data = Struct.new(:title, :param_key, :collection)
  def initialize(data)
    @title = data.title
    @key = data.param_key
    @collection = data.collection || []
  end
end
