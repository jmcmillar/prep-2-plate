require "test_helper"

class Admin::MealTypes::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @meal_type = meal_types(:one)
    @facade = Admin::MealTypes::ResourceFacade.new(@meal_type)
  end

  def test_headers_returns_table_header_components
    headers = Admin::MealTypes::ResourceFacade.headers
    assert_equal 1, headers.size
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::MealTypes::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_name_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.name
  end

  def test_id_returns_formatted_string
    assert_equal "meal_type_#{@meal_type.id}", @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
