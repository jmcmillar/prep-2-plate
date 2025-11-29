require "test_helper"

class ShoppingListItems::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @shopping_list_item = shopping_list_items(:one)
    @facade = ShoppingListItems::ResourceFacade.new(@shopping_list_item)
  end

  def test_resource_returns_shopping_list_item
    assert_equal @shopping_list_item, @facade.resource
  end

  def test_id_returns_formatted_string
    assert_equal "shopping_list_item_#{@shopping_list_item.id}", @facade.id
  end

  def test_name_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.name
  end

  def test_action_returns_table_icon_actions_component
    assert_instance_of Table::IconActionsComponent, @facade.action
  end
end
