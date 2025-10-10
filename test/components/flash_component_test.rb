require "test_helper"

class FlashComponentTest < ViewComponent::TestCase
  setup do
    @alert = FlashComponent.new(scheme: "alert-warning", icon: :exclamation_triangle, message: "Bad News Bears")
    @notice = FlashComponent.new(scheme: "alert-success", icon: :check_circle, message: "Good News")
  end

  def test_alert_flash
    render_inline(@alert)

    assert_selector ".alert-warning"
    assert_text "Bad News Bears"
    assert_selector ".fa-exclamation-triangle"
  end

  def test_notice_flash
    render_inline(@notice)

    assert_selector ".alert-success"
    assert_text "Good News"
    assert_selector ".fa-check-circle"
  end
end
