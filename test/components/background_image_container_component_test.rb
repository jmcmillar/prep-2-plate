# frozen_string_literal: true

require "test_helper"

class BackgroundImageContainerComponentTest < ViewComponent::TestCase
  setup do
    @default_styles = ["no-repeat", "cover", "center top"]
  end
  def test_component_renders_default
    render_inline(BackgroundImageContainerComponent.new(
      image: ""
    ))
    component_styles = page.find("div.relative", match: :first)["style"]
    @default_styles.each do |style|
      assert style.in? component_styles
    end
  end

  def test_component_renders_with_block
    render_inline(
      BackgroundImageContainerComponent.new(
        image: ""
      )
    ) { "Block Text" }

    refute_selector "div.h-full.w-full.absolute.bg-black.opacity-50"
    assert_text "Block Text"
  end

  def test_component_renders_with_overlay
    render_inline(
      BackgroundImageContainerComponent.new(
        image: "",
        settings: BackgroundImageData.new(overlay: true)
      )
    ) { "Block Text" }
    assert_selector "div.h-full.w-full.absolute.bg-black.opacity-50"
    assert_text "Block Text"
  end

  def test_component_renders_with_custom_background_settings
    render_inline(
      BackgroundImageContainerComponent.new(
        image: "",
        settings: BackgroundImageData.new(position: "center")
      )
    )
    component_styles = page.find("div.relative", match: :first)["style"]
    @default_styles.tap(&:pop).each do |style|
      assert style.in? component_styles
    end
  end
end
