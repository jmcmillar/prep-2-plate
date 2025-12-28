require "test_helper"

class ShoppingListItems::ArchiveTest < ActiveSupport::TestCase
  def test_archives_item_successfully
    item = shopping_list_items(:one)

    result = ShoppingListItems::Archive.call(item)

    assert result
    assert item.reload.archived?
  end

  def test_decrements_counter_cache
    shopping_list = shopping_lists(:one)
    item = shopping_list.shopping_list_items.create!(name: "Test")
    initial_count = shopping_list.reload.shopping_list_items_count

    ShoppingListItems::Archive.call(item)

    assert_equal initial_count - 1, shopping_list.reload.shopping_list_items_count
  end

  def test_preserves_all_item_attributes
    item = ShoppingListItem.create!(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      ingredient_id: ingredients(:one).id,
      packaging_form: "canned",
      preparation_style: "diced"
    )

    ShoppingListItems::Archive.call(item)

    archived = ShoppingListItem.unscoped.find(item.id)
    assert_equal "tomatoes", archived.name
    assert_equal ingredients(:one).id, archived.ingredient_id
    assert_equal "canned", archived.packaging_form
    assert_equal "diced", archived.preparation_style
  end

  def test_returns_false_if_already_archived
    item = shopping_list_items(:one)
    item.archive!

    result = ShoppingListItems::Archive.call(item)

    assert_equal false, result
  end

  def test_returns_false_when_update_fails
    item = shopping_list_items(:one)

    # Make the item invalid to trigger an error
    def item.update!(*args)
      raise ActiveRecord::RecordInvalid.new(self)
    end

    result = ShoppingListItems::Archive.call(item)

    assert_equal false, result
  end
end
