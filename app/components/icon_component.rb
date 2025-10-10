class IconComponent < ApplicationComponent
  Data = Struct.new(:name, :weight, :html_options) do
    def initialize(*)
      super
      self.weight ||= :fal
      self.html_options ||= {}
    end
  end
  
  def initialize(icon_data)
    @icon_data = icon_data
    icon_data.html_options[:class] = class_names(@icon_data.weight, "fa-#{@icon_data.name.to_s.dasherize}", icon_data.html_options[:class])
    @html_options = extract_html_from_options(icon_data.html_options)
  end

  def call
    tag.i(**@html_options) + content_tag
  end

  def content_tag
    return unless content
    tag.span(content, class: 'ml-2')
  end
end
