require "test_helper"

class Admin::Users::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Admin::Users::ResourceFacade.new(@user)
  end

  def test_headers_return_array
    assert @facade.class.headers.is_a?(Array)
  end

  def test_to_row_returns_table_row_component
    assert_instance_of Table::RowComponent, @facade.class.to_row(@facade)
  end

  def test_first_name
    assert_data_cell @user.first_name, @facade.first_name
  end

  def test_last_name
    assert_data_cell @user.last_name, @facade.last_name
  end

  def test_email
    assert_data_cell @user.email, @facade.email
  end

  def test_admin
    assert_data_cell "Yes", @facade.admin
  end

  def test_id
    assert_equal(["user", @user.id].join("_"), @facade.id)
  end

  def test_action
    assert_instance_of Table::IconActionsComponent, @facade.action
  end

  private

  # ViewComponents do not define ==, so compare the type and the wrapped value.
  def assert_data_cell(expected, component)
    assert_instance_of Table::DataComponent, component
    assert_equal expected, component.instance_variable_get(:@data)
  end
end
