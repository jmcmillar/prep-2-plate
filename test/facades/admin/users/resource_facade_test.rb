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
    assert_equal(
      Table::DataComponent.new(@user.first_name),
      @facade.first_name
    )
  end

  def test_last_name
    assert_equal(
      Table::DataComponent.new(@user.last_name),
      @facade.last_name
    )
  end

  def test_email
    assert_equal(
      Table::DataComponent.new(@user.email),
      @facade.email
    )
  end

  def test_admin
    assert_equal(
      Table::DataComponent.new("Yes"),
      @facade.admin
    )
  end

  def test_id
    assert_equal(["user", @user.id].join("_"), @facade.id)
  end

  def test_action
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
