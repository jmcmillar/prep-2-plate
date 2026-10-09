require "test_helper"

class SupportsControllerTest < ActionDispatch::IntegrationTest
  def test_show_is_public
    get support_path

    assert_response :success
    assert_select "h1", "Support"
  end
end
