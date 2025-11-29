require "test_helper"

class Admin::RecipeIngredients::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @recipe_ingredient = recipe_ingredients(:one)
    @facade = Admin::RecipeIngredients::ResourceFacade.new(@recipe_ingredient)
  end

  def test_headers_returns_table_header_components
    headers = Admin::RecipeIngredients::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::RecipeIngredients::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /recipe_ingredient_/, @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
