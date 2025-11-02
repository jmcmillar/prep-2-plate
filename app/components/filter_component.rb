class FilterComponent < ApplicationComponent
  Data = Struct.new(:title, :param_key, :collection, :advance)
  def initialize(data)
    @title = data.title
    @key = data.param_key
    @collection = data.collection || []
    @advance = data.advance.nil? ? true : data.advance
  end
end
