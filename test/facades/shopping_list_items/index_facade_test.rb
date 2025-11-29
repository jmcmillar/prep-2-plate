require "test_helper"

class ShoppingListItems::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @shopping_list = @user.shopping_lists.create!(name: "Weekly Groceries")
    @item = @shopping_list.shopping_list_items.create!(name: "Milk")
    @facade = ShoppingListItems::IndexFacade.new(@user, { shopping_list_id: @shopping_list.id })
  end

  def test_base_collection
    assert_includes @facade.base_collection, @item
  end

  def test_collection
    assert_kind_of CollectionBuilder, @facade.collection
  end

  def test_headers
    assert_kind_of Array, @facade.headers
  end

  def test_rows
    assert_kind_of Array, @facade.rows
  end

  def test_header_actions
    actions = @facade.header_actions
    
    assert_equal 1, actions.length
    assert_kind_of IconLinkComponent::Data, actions.first
  end

  def test_new_action_data
    action = @facade.new_action_data
    
    assert_kind_of IconLinkComponent::Data, action
    assert_equal :plus, action.icon
    assert_equal "New Item", action.label
  end
end
