
class IconLinkComponent < ApplicationComponent
  Data = Struct.new(:path, :icon, :label, :options) do
    def initialize(*)
      super
      self.options ||= {}
    end
  end
  def initialize(icon_link:, **options)
    @icon_link = icon_link
    @icon_link.options[:class] = class_names("mx-1 relative", @icon_link.options[:class], options[:class])
    @html_options = extract_html_from_options(@icon_link.options,  %i[class data aria style method remote target])
  end

  def call
    link_to(@icon_link.path, aria: {label: @icon_link.label}, title: @icon_link.label, **@html_options) do
      concat render(IconComponent.new(IconComponent::Data[@icon_link.icon]))
      concat content
    end
  end

  def render?
    @icon_link.path.present?
  end
end
