# frozen_string_literal: true

require "test_helper"

class ButtonLinkComponentTest < ViewComponent::TestCase
  setup do
    @allowable_schemes = %i[primary light link].freeze
    @button_link_data = ButtonLinkComponent::Data[
      "Default Button",
      "/",
      nil,
      :primary
    ]
    @component = ButtonLinkComponent
  end

  def test_component_with_default_scheme
    render_inline @component.new(button_link_data: @button_link_data)
    assert_link "Default Button", class: "bg-primary text-white font-bold py-2 px-4 rounded", href: "/"
  end

  def test_allowable_schemes
    assert_equal ButtonLinkSchemeData::SCHEME_MAP.members, @allowable_schemes
  end
end
