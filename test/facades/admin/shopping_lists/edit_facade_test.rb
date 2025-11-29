require "test_helper"

class Admin::ShoppingLists::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @facade = Admin::ShoppingLists::EditFacade.new(@admin, { id: @shopping_list.id })
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
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

  def test_form_url
    assert_equal [:admin, @shopping_list], @facade.form_url
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping Lists", trail[1].text
    assert_equal "Edit", trail[2].text
  end
end
