require "test_helper"

class Admin::Ingredients::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::ResourceFacade.new(@ingredient)
  end

  def test_headers_returns_table_header_components
    headers = Admin::Ingredients::ResourceFacade.headers
    assert_equal 1, headers.size
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::Ingredients::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_name_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.name
  end

  def test_id_returns_formatted_string
    assert_equal "ingredient_#{@ingredient.id}", @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end

  def test_action_turbo_data_returns_turbo_data
    turbo_data = @facade.action_turbo_data
    assert_instance_of TurboData, turbo_data
  end
end
