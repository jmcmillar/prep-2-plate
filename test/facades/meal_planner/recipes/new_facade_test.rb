require "test_helper"

class MealPlanner::Recipes::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @session = { selected_recipe_ids: [], meal_plan: {} }
    @facade = MealPlanner::Recipes::NewFacade.new(@user, { recipe_id: @recipe.id, day: "monday" }, session: @session)
  end

  def test_resource
    assert_equal @recipe, @facade.resource
  end

  def test_selected_recipes
    @session[:selected_recipe_ids] = [@recipe.id]
    
    recipes = @facade.selected_recipes
    assert_equal 1, recipes.length
    assert_kind_of Recipes::ResourceFacade, recipes.first
  end

  def test_append_to_meal_plan
    @facade.append_to_meal_plan
    
    assert @session[:meal_plan]["monday"].present?
    assert_includes @session[:meal_plan]["monday"]["recipes"].map { |r| r["id"] }, @recipe.id
  end

  def test_append_to_selected_recipes
    # Call resource first to ensure @resource is set
    @facade.resource
    @facade.append_to_selected_recipes
    
    assert_includes @session[:selected_recipe_ids], @recipe.id
  end

  def test_export_button_data
    button_data = @facade.export_button_data
    
    assert_kind_of ModalButtonComponent::Data, button_data
    assert_equal "Export Meal Plan", button_data.label
  end
end
