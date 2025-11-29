require "test_helper"

class Admin::Recipes::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @facade = Admin::Recipes::ShowFacade.new(@admin, { id: @recipe.id })
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_recipe_ingredients
    ingredients = @facade.recipe_ingredients
    
    assert_kind_of Array, ingredients
  end

  def test_meal_types
    meal_types = @facade.meal_types
    
    assert_kind_of String, meal_types
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipes", trail[1].text
  end

  def test_edit_action_data
    action = @facade.edit_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "Recipe", action.label
  end
end
