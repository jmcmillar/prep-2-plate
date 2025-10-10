class ContainerComponent < ApplicationComponent
  def initialize(**options)
    options[:class] = class_names(options[:class], "container mx-auto px-4")
    @html_options = extract_html_from_options(options)
  end
end
