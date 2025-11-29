require "test_helper"

class Admin::MealPlanIngredients::ResourceFacadeTest < ActiveSupport::TestCase
  def setup
    # MealPlanIngredient is a database view, so we query an existing one
    @meal_plan_ingredient = MealPlanIngredient.first
    skip "No meal plan ingredients available" if @meal_plan_ingredient.nil?
    @facade = Admin::MealPlanIngredients::ResourceFacade.new(@meal_plan_ingredient)
  end

  def test_headers_returns_table_header_components
    headers = Admin::MealPlanIngredients::ResourceFacade.headers
    assert headers.size > 0
    assert_instance_of Table::DefaultHeaderComponent, headers.first
  end

  def test_to_row_returns_table_row_component
    row = Admin::MealPlanIngredients::ResourceFacade.to_row(@facade)
    assert_instance_of Table::RowComponent, row
  end

  def test_id_returns_formatted_string
    assert_match /meal_plan_ingredient_/, @facade.id
  end
end
