require "test_helper"

class Admin::ShoppingLists::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @facade = Admin::ShoppingLists::NewFacade.new(@admin, { user_id: @user.id })
  end

  def test_shopping_list
    list = @facade.shopping_list
    
    assert_kind_of ShoppingList, list
    assert list.new_record?
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

  def test_shopping_list_user
    assert_equal @user, @facade.shopping_list_user
  end

  def test_form_url
    assert_equal [:admin, @user, :shopping_lists], @facade.form_url
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping Lists", trail[1].text
    assert_equal "New", trail[2].text
  end
end
