class Form::CheckboxGroupTagsComponent < ApplicationComponent
  DEFAULT_CLASSES = "mb-3"
  attr_accessor :form

  def initialize(method, collection, value_method, text_method, form, **options)
    @method = method
    @form = form
    @collection = collection
    @text_method = text_method
    @value_method = value_method
    options[:class] = class_names(DEFAULT_CLASSES, options[:class])
    options[:data] = data_attributes
    @html_options = extract_html_from_options(options)
  end

  private

  def data_attributes
    {
      controller: "checkbox-group",
      "checkbox-group-collection-value": @collection,
      "checkbox-group-whitelist-value": @collection.pluck(@text_method),
    }
  end
end
