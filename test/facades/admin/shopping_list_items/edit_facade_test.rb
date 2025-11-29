require "test_helper"

class Admin::ShoppingListItems::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @item = @shopping_list.shopping_list_items.create!(name: "Test Item")
    @facade = Admin::ShoppingListItems::EditFacade.new(@admin, { id: @item.id })
  end

  def test_shopping_list_item
    assert_equal @item, @facade.shopping_list_item
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_active_key
    assert_equal :admin_shopping_lists, @facade.active_key
  end

  def test_breadcrumb_trail
    trail = @facade.breadcrumb_trail
    
    assert_equal 3, trail.length
    assert_equal "Admin", trail[0].text
    assert_equal "Shopping List Items", trail[1].text
    assert_equal "Edit", trail[2].text
  end

  def test_form_url
    assert_equal [:admin, @item], @facade.form_url
  end

  def test_cancel_path
    assert_equal [:admin, @shopping_list, :shopping_list_items], @facade.cancel_path
  end
end
