# frozen_string_literal: true

require "test_helper"

class NavItemComponentTest < ViewComponent::TestCase
  def setup
    @nav_item = NavItemComponent::Data["Library", "/library", "mx-1"]
    @component = NavItemComponent
  end

  def test_component_renders
    render_inline @component.new(nav_item: @nav_item)
    assert_link "Library", href: "/library", class: "mx-1"
  end

  def test_component_renders_with_collection
    render_inline @component.with_collection([@nav_item, @nav_item])
    assert_link "Library", href: "/library", class: "mx-1", count: 2
  end
end
