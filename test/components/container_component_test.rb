# frozen_string_literal: true

require "test_helper"

class ContainerComponentTest < ViewComponent::TestCase
  def test_component_renders
    render_inline ContainerComponent.new.with_content("block")

    assert_selector "div", class: "container mx-auto px-4"
    assert_text "block"
  end

  def test_component_renders_with_additional_classes
    render_inline ContainerComponent.new(class: "p-4").with_content("block")

    assert_selector "div", class: "p-4 container mx-auto px-4"
    assert_text "block"
  end
end
