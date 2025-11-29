require "test_helper"

class MealPlanner::Recipes::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @session = { selected_recipe_ids: [@recipe.id] }
    @facade = MealPlanner::Recipes::DestroyFacade.new(@user, { id: @recipe.id }, session: @session)
  end

  def test_resource
    assert_equal @recipe, @facade.resource
  end

  def test_selected_recipes
    recipes = @facade.selected_recipes
    
    assert_equal 1, recipes.length
    assert_kind_of Recipes::ResourceFacade, recipes.first
  end

  def test_export_button_data
    button_data = @facade.export_button_data
    
    assert_kind_of ModalButtonComponent::Data, button_data
    assert_equal "Export Meal Plan", button_data.label
  end
end
