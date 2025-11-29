require "test_helper"

class Admin::Recipes::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    # Create a recipe without user_recipe association (admin recipes only show recipes without user_recipe)
    @recipe = Recipe.create!(name: "Admin Recipe", recipe_import_id: nil)
    @facade = Admin::Recipes::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_recipes, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @recipe
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Recipes", trail.last.text
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name, Meal Types, Categories", search_data.label
  end

  def test_header_actions
    actions = @facade.header_actions
    
    assert_equal 2, actions.length
  end
end
