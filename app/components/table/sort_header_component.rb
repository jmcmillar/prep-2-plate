class Table::SortHeaderComponent < ApplicationComponent
  def initialize(sort_data)
    @sort_data = sort_data
  end

  def call
    sort_link(@sort_data.collection, @sort_data.value_method, class: "flex")
  end
end
