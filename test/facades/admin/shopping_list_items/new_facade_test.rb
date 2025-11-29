require "test_helper"

class Admin::ShoppingListItems::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @facade = Admin::ShoppingListItems::NewFacade.new(@admin, { shopping_list_id: @shopping_list.id })
  end

  def test_shopping_list_item
    item = @facade.shopping_list_item
    
    assert_kind_of ShoppingListItem, item
    assert item.new_record?
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

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping List Items", trail[1].text
    assert_equal "New", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @shopping_list, :shopping_list_items], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @shopping_list, :shopping_list_items], @facade.cancel_path
  end
end
