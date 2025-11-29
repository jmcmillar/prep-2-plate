require "test_helper"

class ShoppingLists::EditFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @facade = ShoppingLists::EditFacade.new(@user, { id: @shopping_list.id })
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end

  def test_set_others_false
    other_list = @user.shopping_lists.create!(name: "Other List", current: true)
    
    @facade.set_others_false
    
    assert_not other_list.reload.current
  end
end
