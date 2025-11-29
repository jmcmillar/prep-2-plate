require "test_helper"

class ShoppingLists::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @shopping_list = shopping_lists(:one)
    @facade = ShoppingLists::ResourceFacade.new(@shopping_list)
  end

  def test_resource_returns_shopping_list
    assert_equal @shopping_list, @facade.resource
  end

  def test_id_returns_formatted_string
    assert_equal "shopping_list_#{@shopping_list.id}", @facade.id
  end

  def test_name_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.name
  end

  def test_item_count_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.item_count
  end

  def test_last_updated_at_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.last_updated_at
  end
end
