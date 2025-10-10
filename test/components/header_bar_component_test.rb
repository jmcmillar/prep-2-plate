# frozen_string_literal: true

require "test_helper"

class HeaderBarComponentTest < ViewComponent::TestCase
  def setup
    @breadcrumb_collection = [
      BreadcrumbComponent::Data["Home", "/"],
      BreadcrumbComponent::Data["Library", "/library"],
    ]
    @icon_link_collection = [
      IconLinkComponent::Data["/library", "fas fa-book", "Library"],
      IconLinkComponent::Data["/library", "fas fa-book", "Library"],
    ]
  end

  def test_component_renders
    render_inline(HeaderBarComponent.new(title: "Hello"))

    assert_selector "h1", text: "Hello"
  end

  def test_component_renders_with_breadcrumb
    render_inline(HeaderBarComponent.new(title: "Hello")) do |component|
      component.with_breadcrumb_collection(@breadcrumb_collection)
    end

    assert_selector "h1", text: "Hello"
    assert_selector "a", count: 2
  end

  def test_component_renders_with_icon_links
    render_inline(HeaderBarComponent.new(title: "Hello")) do |component|
      component.with_icon_link_collection(@icon_link_collection)
    end

    assert_selector "h1", text: "Hello"
    assert_selector "a", count: 2
  end
end
