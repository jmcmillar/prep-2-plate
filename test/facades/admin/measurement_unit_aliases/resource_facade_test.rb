require "test_helper"

class Admin::MeasurementUnitAliases::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @measurement_unit_alias = measurement_unit_aliases(:one)
    @facade = Admin::MeasurementUnitAliases::ResourceFacade.new(@measurement_unit_alias)
  end

  def test_headers_returns_table_header_components
    headers = Admin::MeasurementUnitAliases::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::MeasurementUnitAliases::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /measurement_unit_alias_/, @facade.id
  end

  def test_action_returns_table_icon_actions_component
    assert_instance_of Table::IconActionsComponent, @facade.action
  end
end
