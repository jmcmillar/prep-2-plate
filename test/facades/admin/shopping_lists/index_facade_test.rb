require "test_helper"

class Admin::ShoppingLists::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @shopping_list = @other_user.shopping_lists.create!(name: "Weekly Groceries")
    @facade = Admin::ShoppingLists::IndexFacade.new(@user, { user_id: @other_user.id })
  end

  def test_active_key
    assert_equal :admin_shopping_lists, @facade.active_key
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_shopping_list_user
    assert_equal @other_user, @facade.shopping_list_user
  end

  def test_nav_resource
    assert_equal @other_user, @facade.nav_resource
  end

  def test_base_collection
    assert_includes @facade.base_collection, @shopping_list
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 2, trail.length
    assert_equal "Admin", trail.first.text
    assert_equal "Shopping Lists", trail.last.text
  end
end
