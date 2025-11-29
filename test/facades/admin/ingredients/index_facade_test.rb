require "test_helper"

class Admin::Ingredients::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @facade = Admin::Ingredients::IndexFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :admin_ingredients, @facade.active_key
  end

  def test_base_collection
    assert_includes @facade.base_collection, @ingredient
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Ingredients", trail.last.text
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal "Search Name", search_data.label
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Ingredient", action.label
  end
end
