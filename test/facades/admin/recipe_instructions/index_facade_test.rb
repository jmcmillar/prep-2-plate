require "test_helper"

class Admin::RecipeInstructions::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @recipe = recipes(:one)
    @facade = Admin::RecipeInstructions::IndexFacade.new(@admin, { recipe_id: @recipe.id })
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_recipe
    assert_equal @recipe, @facade.recipe
  end

  def test_base_collection
    collection = @facade.base_collection
    
    assert_kind_of ActiveRecord::Relation, collection
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Recipe Instructions", trail[1].text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Recipe Instruction", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::RecipeInstructions::ResourceFacade, @facade.resource_facade_class
  end
end
