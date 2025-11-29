require "test_helper"

class Admin::RecipeIngredients::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @ingredient = ingredients(:one)
    @unit = measurement_units(:one)
    @recipe_ingredient = @recipe.recipe_ingredients.create!(ingredient: @ingredient, measurement_unit: @unit)
    @facade = Admin::RecipeIngredients::IndexFacade.new(@admin, { recipe_id: @recipe.id })
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_base_collection
    assert_includes @facade.base_collection, @recipe_ingredient
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Recipe Ingredients", trail.last.text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Recipe Ingredient", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::RecipeIngredients::ResourceFacade, @facade.resource_facade_class
  end
end
