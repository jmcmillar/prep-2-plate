require "test_helper"

class ShoppingLists::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @facade = ShoppingLists::ShowFacade.new(@user, { id: @shopping_list.id })
  end

  def test_resource
    assert_equal @shopping_list, @facade.resource
  end

  def test_name
    assert_equal "Weekly Groceries", @facade.name
  end

  def test_shopping_list_items
    item = @shopping_list.shopping_list_items.create!(name: "Milk")
    
    assert_includes @facade.shopping_list_items, item
  end
end
