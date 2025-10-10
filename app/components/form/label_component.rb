class Form::LabelComponent < ApplicationComponent
  DEFAULT_CLASSES = "font-medium text-sm text-gray-800 mb-1"

  def initialize(method, text, **options)
    @method = method
    @text = text || @method.to_s.titleize
    options[:class] = class_names(DEFAULT_CLASSES, options[:class])
    @html_options = extract_html_from_options(options)
    @required = options[:required]
  end

  private

  def required_span
    return unless @required
    
    tag.span(class: "text-red-700") { "* " }
  end
end