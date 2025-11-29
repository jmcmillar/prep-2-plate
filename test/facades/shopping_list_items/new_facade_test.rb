require "test_helper"

class ShoppingListItems::NewFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @facade = ShoppingListItems::NewFacade.new(@user, { shopping_list_id: @shopping_list.id })
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_shopping_list_item_is_not_persisted
    assert @facade.shopping_list_item.new_record?
  end

  def test_shopping_list_item_belongs_to_shopping_list
    assert_equal @shopping_list, @facade.shopping_list_item.shopping_list
  end

  def test_form_url
    expected = { controller: "shopping_list_items", shopping_list_id: @shopping_list.id, action: "create" }
    assert_equal expected, @facade.form_url
  end

  def test_cancel_path
    expected = { controller: "shopping_list_items", shopping_list_id: @shopping_list.id, action: "index" }
    assert_equal expected, @facade.cancel_path
  end
end
