require "test_helper"

class ShoppingListItemTest < ActiveSupport::TestCase
  # Association tests
  def test_belongs_to_shopping_list
    item = shopping_list_items(:one)
    assert_respond_to item, :shopping_list
    assert_instance_of ShoppingList, item.shopping_list
  end

  def test_belongs_to_ingredient
    item = ShoppingListItem.new(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      ingredient: ingredients(:one)
    )
    assert item.save
    assert_equal ingredients(:one), item.ingredient
  end

  def test_ingredient_is_optional
    item = ShoppingListItem.new(
      name: "Custom item",
      shopping_list: shopping_lists(:one)
    )
    assert item.valid?, "Item should be valid without an ingredient"
  end

  # Validation tests
  def test_name_presence
    item = ShoppingListItem.new(shopping_list: shopping_lists(:one))
    assert_not item.valid?
    assert_includes item.errors[:name], "can't be blank"
  end

  def test_packaging_form_must_be_valid
    item = shopping_list_items(:one)
    item.packaging_form = "invalid"
    assert_not item.valid?
    assert_includes item.errors[:packaging_form], "is not included in the list"
  end

  def test_packaging_form_allows_valid_values
    item = shopping_list_items(:one)
    Ingredient::PACKAGING_FORMS.keys.each do |packaging|
      item.packaging_form = packaging.to_s
      assert item.valid?, "#{packaging} should be a valid packaging_form"
    end
  end

  def test_packaging_form_can_be_nil
    item = shopping_list_items(:one)
    item.packaging_form = nil
    assert item.valid?, "packaging_form should allow nil"
  end

  def test_packaging_form_can_be_blank
    item = shopping_list_items(:one)
    item.packaging_form = ""
    assert item.valid?, "packaging_form should allow blank"
  end

  def test_preparation_style_must_be_valid
    item = shopping_list_items(:one)
    item.preparation_style = "invalid"
    assert_not item.valid?
    assert_includes item.errors[:preparation_style], "is not included in the list"
  end

  def test_preparation_style_allows_valid_values
    item = shopping_list_items(:one)
    Ingredient::PREPARATION_STYLES.keys.each do |preparation|
      item.preparation_style = preparation.to_s
      assert item.valid?, "#{preparation} should be a valid preparation_style"
    end
  end

  def test_preparation_style_can_be_nil
    item = shopping_list_items(:one)
    item.preparation_style = nil
    assert item.valid?, "preparation_style should allow nil"
  end

  def test_preparation_style_can_be_blank
    item = shopping_list_items(:one)
    item.preparation_style = ""
    assert item.valid?, "preparation_style should allow blank"
  end

  # display_name tests
  def test_display_name_with_name_only
    item = ShoppingListItem.new(name: "tomatoes")
    assert_equal "tomatoes", item.display_name
  end

  def test_display_name_with_packaging_only
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned"
    )
    assert_equal "Canned tomatoes", item.display_name
  end

  def test_display_name_with_preparation_only
    item = ShoppingListItem.new(
      name: "tomatoes",
      preparation_style: "diced"
    )
    assert_equal "Diced tomatoes", item.display_name
  end

  def test_display_name_with_packaging_and_preparation
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced"
    )
    assert_equal "Canned Diced tomatoes", item.display_name
  end

  def test_display_name_with_blank_packaging_and_preparation
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "",
      preparation_style: ""
    )
    assert_equal "tomatoes", item.display_name
  end

  def test_display_name_with_nil_packaging_and_preparation
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: nil,
      preparation_style: nil
    )
    assert_equal "tomatoes", item.display_name
  end

  # Backward compatibility test
  def test_backward_compatibility_with_name_only_items
    item = ShoppingListItem.new(
      name: "Custom shopping item",
      shopping_list: shopping_lists(:one)
    )
    assert item.valid?, "Existing items with only name should still be valid"
    assert item.save, "Should be able to save items with only name"
  end

  # Counter cache test
  def test_shopping_list_counter_cache
    shopping_list = shopping_lists(:one)
    initial_count = shopping_list.shopping_list_items_count || 0

    item = shopping_list.shopping_list_items.create!(name: "New item")
    shopping_list.reload
    assert_equal initial_count + 1, shopping_list.shopping_list_items_count

    item.destroy
    shopping_list.reload
    assert_equal initial_count, shopping_list.shopping_list_items_count
  end
end
