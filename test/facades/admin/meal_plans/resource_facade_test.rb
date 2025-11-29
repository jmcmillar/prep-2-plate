require "test_helper"

class Admin::MealPlans::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @meal_plan = meal_plans(:one)
    @facade = Admin::MealPlans::ResourceFacade.new(@meal_plan)
  end

  def test_headers_returns_table_header_components
    headers = Admin::MealPlans::ResourceFacade.headers
    assert_equal 1, headers.size
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::MealPlans::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_name_returns_table_data_component
    assert_instance_of Table::DataComponent, @facade.name
  end

  def test_id_returns_formatted_string
    assert_equal "meal_plan_#{@meal_plan.id}", @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
