require "test_helper"

class MealPlanners::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @session = { selected_recipe_ids: [@recipe.id], meal_plan: { name: "Test Plan" } }
    @facade = MealPlanners::ShowFacade.new(@user, { start_on: "2025-11-24", end_on: "2025-11-30" }, session: @session)
  end

  def test_selected_recipes
    recipes = @facade.selected_recipes
    
    assert_equal 1, recipes.length
    assert_kind_of Recipes::ResourceFacade, recipes.first
  end

  def test_plan
    assert_equal({ name: "Test Plan" }, @facade.plan)
  end

  def test_export_button_data
    button_data = @facade.export_button_data
    
    assert_kind_of ModalButtonComponent::Data, button_data
    assert_equal "Shopping List", button_data.label
  end

  def test_previous_week_link_data
    link_data = @facade.previous_week_link_data
    
    assert_kind_of ButtonLinkComponent::Data, link_data
    assert_equal "Prev", link_data.label
  end

  def test_next_week_link_data
    link_data = @facade.next_week_link_data
    
    assert_kind_of ButtonLinkComponent::Data, link_data
    assert_equal "Next", link_data.label
  end

  def test_active_key
    assert_equal :meal_planner, @facade.active_key
  end

  def test_current_week
    expected_range = Date.parse("2025-11-24")..Date.parse("2025-11-30")
    assert_equal expected_range, @facade.current_week
  end
end
