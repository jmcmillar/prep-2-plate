require "test_helper"

class Admin::ShoppingListItems::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @item = @shopping_list.shopping_list_items.create!(
      name: "Test Item"
    )
    @facade = Admin::ShoppingListItems::IndexFacade.new(@admin, { shopping_list_id: @shopping_list.id })
  end

  def test_active_key
    assert_equal :admin_shopping_lists, @facade.active_key
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_nav_resource
    assert_equal @user, @facade.nav_resource
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_base_collection
    assert_includes @facade.base_collection, @item
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 4, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping Lists", trail[1].text
    assert_equal "Items", trail[3].text
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal "New Item", action.label
  end

  def test_resource_facade_class
    assert_equal Admin::ShoppingListItems::ResourceFacade, @facade.resource_facade_class
  end
end
