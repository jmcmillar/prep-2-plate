require "test_helper"

class Admin::ShoppingLists::DestroyFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
    @shopping_list = @user.shopping_lists.create!(name: "Test List", current: false)
    @facade = Admin::ShoppingLists::DestroyFacade.new(@admin, { id: @shopping_list.id })
  end

  def test_shopping_list
    assert_equal @shopping_list, @facade.shopping_list
  end
end
