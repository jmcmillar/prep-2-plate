require "test_helper"

class Admin::Resources::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @resource = resources(:one)
    @facade = Admin::Resources::ResourceFacade.new(@resource)
  end

  def test_headers_returns_table_header_components
    headers = Admin::Resources::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::Resources::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /resource_/, @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
