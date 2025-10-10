# frozen_string_literal: true

require "test_helper"

class IconComponentTest < ViewComponent::TestCase
  def test_component_renders_with_default_icon_weight
    render_inline IconComponent.new(IconComponent::Data[:book])
    assert_selector "i", class: "fal fa-book"
  end

  def test_component_renders_with_custom_icon_weight
    render_inline IconComponent.new(IconComponent::Data[:book, :far])
    assert_selector "i", class: "far fa-book"
  end

  def test_component_renders_with_additional_classes
    render_inline IconComponent.new(IconComponent::Data[:book, :fal, {class: "fs-1"}])
    assert_selector "i", class: "fal fa-book fs-1"
  end
end
