require "test_helper"

class Admin::ShoppingListItems::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @item = @shopping_list.shopping_list_items.create!(name: "Test Item")
    @facade = Admin::ShoppingListItems::DestroyFacade.new(@admin, { id: @item.id })
  end

  def test_shopping_list_item
    assert_equal @item, @facade.shopping_list_item
  end
end
