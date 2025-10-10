require "test_helper"

class PublicControllerTest < ActionDispatch::IntegrationTest
  def test_get_index_success
    get root_path
    assert_response :success
  end
end
