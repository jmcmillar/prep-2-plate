require "test_helper"

class Admin::ShoppingLists::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @shopping_list = @other_user.shopping_lists.create!(name: "Weekly Groceries")
    @facade = Admin::ShoppingLists::ShowFacade.new(@user, { id: @shopping_list.id })
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_menu
    assert_equal :admin_user_menu, @facade.menu
  end

  def test_active_key
    assert_equal :admin_shopping_lists, @facade.active_key
  end

  def test_nav_resource
    assert_equal @other_user, @facade.nav_resource
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping Lists", trail[1].text
    assert_equal "Weekly Groceries", trail[2].text
  end

  def test_header_actions
    actions = @facade.header_actions
    
    assert_equal 1, actions.length
  end
end
