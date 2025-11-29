require "test_helper"

class Admin::UserRecipes::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @user_recipe = user_recipes(:one)
    @facade = Admin::UserRecipes::ResourceFacade.new(@user_recipe)
  end

  def test_headers_returns_table_header_components
    headers = Admin::UserRecipes::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::UserRecipes::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /user_recipe_/, @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
