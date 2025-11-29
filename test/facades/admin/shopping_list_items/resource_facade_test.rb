require "test_helper"

class Admin::ShoppingListItems::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @shopping_list_item = shopping_list_items(:one)
    @facade = Admin::ShoppingListItems::ResourceFacade.new(@shopping_list_item)
  end

  def test_headers_returns_table_header_components
    headers = Admin::ShoppingListItems::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::ShoppingListItems::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /shopping_list_item_/, @facade.id
  end

  def test_action_returns_table_icon_actions_component
    assert_instance_of Table::IconActionsComponent, @facade.action
  end
end
