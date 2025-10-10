
class Table::RowComponent < ApplicationComponent
  DEFAULT_CLASSES = "odd:bg-white even:bg-gray-50"

  def initialize(td_collection, **options)
    @td_collection = td_collection
    options[:class] = class_names(DEFAULT_CLASSES, options[:class])
    @html_options = extract_html_from_options(options)
  end
end
