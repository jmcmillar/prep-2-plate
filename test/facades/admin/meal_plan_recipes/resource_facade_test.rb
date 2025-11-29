require "test_helper"

class Admin::MealPlanRecipes::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    @meal_plan_recipe = meal_plan_recipes(:one)
    @facade = Admin::MealPlanRecipes::ResourceFacade.new(@meal_plan_recipe)
  end

  def test_headers_returns_table_header_components
    headers = Admin::MealPlanRecipes::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::MealPlanRecipes::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /meal_plan_recipe_/, @facade.id
  end

  def test_action_returns_table_icon_actions_component
    assert_instance_of Table::IconActionsComponent, @facade.action
  end
end
