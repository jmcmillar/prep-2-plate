require "test_helper"

class ShoppingListItems::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @shopping_list_item = @shopping_list.shopping_list_items.create!(name: "Milk")
    @facade = ShoppingListItems::EditFacade.new(@user, { id: @shopping_list_item.id })
  end

  def test_shopping_list_item
    assert_equal @shopping_list_item, @facade.shopping_list_item
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_form_url
    expected = { controller: "shopping_list_items", id: @shopping_list_item.id, action: "update" }
    assert_equal expected, @facade.form_url
  end

  def test_cancel_path
    expected = { controller: "shopping_list_items", shopping_list_id: @shopping_list.id, action: "index" }
    assert_equal expected, @facade.cancel_path
  end

  def test_scoped_to_user
    other_user = users(:two)
    other_shopping_list = other_user.shopping_lists.create!(name: "Other List")
    other_item = other_shopping_list.shopping_list_items.create!(name: "Eggs")
    
    assert_raises(ActiveRecord::RecordNotFound) do
      ShoppingListItems::EditFacade.new(@user, { id: other_item.id }).shopping_list_item
    end
  end
end
