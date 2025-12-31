require "test_helper"

class BadgeComponentTest < ViewComponent::TestCase
  def test_renders_featured_badge
    badge_data = BadgeComponent::Data.new(text: "Featured", scheme: :featured)
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.px-2.py-1.rounded.text-xs.font-semibold.bg-yellow-100.text-yellow-800", text: "Featured"
  end

  def test_renders_success_badge
    badge_data = BadgeComponent::Data.new(text: "Active", scheme: :success)
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.px-2.py-1.rounded.text-xs.font-semibold.bg-green-100.text-green-800", text: "Active"
  end

  def test_renders_default_badge
    badge_data = BadgeComponent::Data.new(text: "Inactive", scheme: :default)
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.px-2.py-1.rounded.text-xs.font-semibold.bg-gray-100.text-gray-800", text: "Inactive"
  end

  def test_renders_muted_badge
    badge_data = BadgeComponent::Data.new(text: "—", scheme: :muted)
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.text-gray-400", text: "—"
  end

  def test_defaults_to_default_scheme
    badge_data = BadgeComponent::Data.new(text: "Default")
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.px-2.py-1.rounded.text-xs.font-semibold.bg-gray-100.text-gray-800", text: "Default"
  end

  def test_accepts_custom_classes
    badge_data = BadgeComponent::Data.new(text: "Custom", scheme: :default, options: { class: "ml-2" })
    render_inline(BadgeComponent.new(badge_data: badge_data))

    assert_selector "span.px-2.py-1.rounded.text-xs.font-semibold.bg-gray-100.text-gray-800.ml-2", text: "Custom"
  end
end
