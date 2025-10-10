# frozen_string_literal: true

class ModalButtonComponent < ApplicationComponent
  Data = Struct.new(:label, :path, :icon, :scheme, :options) do
    def initialize(*)
      super
      self.scheme ||= :primary
      self.options ||= {}
    end
  end
  
  with_collection_parameter :button_link_data
  
  def initialize(button_link_data:)
    @label, @path, @icon, @scheme, @options = button_link_data.to_h.values_at(:label, :path, :icon, :scheme, :options)
    @options[:class] = class_names(ButtonLinkSchemeData::SCHEME_MAP[@scheme], @options[:class])
    @html_options = extract_html_from_options(@options, %i[data class aria target style method])
  end

  def call
    tag.button(
      data: { action: "click->modal#toggle", modal_url: url_for(@path) },
      **@html_options
    ) do
      icon.to_s + @label
    end
  end

  def render?
    @path.present?
  end

  private

  def icon
    return unless @icon.present?
    @icon.then { |i| i && render(IconComponent.new(
      IconComponent::Data[i, :far, {class: "mr-1"}])) }
  end
end
