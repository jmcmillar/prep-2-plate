class BadgeComponent < ApplicationComponent
  Data = Struct.new(:text, :scheme, :options, keyword_init: true) do
    def initialize(*)
      super
      self.scheme ||= :default
      self.options ||= {}
    end
  end

  SCHEME_CLASSES = {
    featured: "bg-yellow-100 text-yellow-800",
    success: "bg-green-100 text-green-800",
    default: "bg-gray-100 text-gray-800",
    muted: "text-gray-400"
  }.freeze

  def initialize(badge_data:)
    @data = badge_data
  end

  def call
    return content_tag(:span, @data.text, class: "text-gray-400") if @data.scheme == :muted

    content_tag(:span, @data.text, class: css_classes)
  end

  private

  def css_classes
    base_classes = "px-2 py-1 rounded text-xs font-semibold"
    scheme_classes = SCHEME_CLASSES[@data.scheme] || SCHEME_CLASSES[:default]
    custom_classes = @data.options[:class]

    [base_classes, scheme_classes, custom_classes].compact.join(" ")
  end
end
