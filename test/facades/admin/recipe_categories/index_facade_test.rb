require "test_helper"

class Admin::RecipeCategories::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe_category = recipe_categories(:one)
    @facade = Admin::RecipeCategories::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_recipe_categories, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @recipe_category
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Recipe Categories", trail.last.text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Recipe Category", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::RecipeCategories::ResourceFacade, @facade.resource_facade_class
  end
end
