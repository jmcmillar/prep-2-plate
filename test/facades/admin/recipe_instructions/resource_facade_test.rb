require "test_helper"

class Admin::RecipeInstructions::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @recipe_instruction = recipe_instructions(:one)
    @facade = Admin::RecipeInstructions::ResourceFacade.new(@recipe_instruction)
  end

  def test_headers_returns_table_header_components
    headers = Admin::RecipeInstructions::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::RecipeInstructions::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /recipe_instruction_/, @facade.id
  end

  def test_action_returns_table_action_component
    assert_instance_of Table::ActionComponent, @facade.action
  end
end
