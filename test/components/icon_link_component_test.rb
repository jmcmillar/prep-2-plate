# frozen_string_literal: true

require "test_helper"

class IconLinkComponentTest < ViewComponent::TestCase
  def setup
    @icon_link_collection = [
      IconLinkComponent::Data["/library", "book", "Library"],
      IconLinkComponent::Data["/library", "book", "Library"],
    ]
  end

  def test_component_renders
    render_inline IconLinkComponent.new(icon_link: @icon_link_collection.first)
    assert_link "Library", href: "/library", class: "mx-1"
  end

  def test_component_renders_with_collection
    render_inline IconLinkComponent.with_collection(@icon_link_collection)
    assert_link "Library", href: "/library", class: "mx-1", count: 2
  end
end
