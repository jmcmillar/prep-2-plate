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

  # Brand validation tests
  def test_brand_allows_nil
    item = ShoppingListItem.new(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      brand: nil
    )
    assert item.valid?, "brand should allow nil"
  end

  def test_brand_allows_blank
    item = ShoppingListItem.new(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      brand: ""
    )
    assert item.valid?, "brand should allow blank"
  end

  def test_brand_allows_valid_string
    item = ShoppingListItem.new(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      brand: "Hunt's"
    )
    assert item.valid?, "brand should allow valid string"
  end

  def test_brand_length_validation
    item = ShoppingListItem.new(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      brand: "a" * 256
    )
    assert_not item.valid?, "brand should not allow strings longer than 255 characters"
    assert_includes item.errors[:brand], "is too long (maximum is 255 characters)"
  end

  # display_name_with_brand tests
  def test_display_name_with_brand_when_brand_present
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "Hunt's"
    )
    assert_equal "Canned Diced tomatoes (Hunt's)", item.display_name_with_brand
  end

  def test_display_name_with_brand_when_brand_nil
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )
    assert_equal "Canned Diced tomatoes", item.display_name_with_brand
  end

  def test_display_name_with_brand_when_brand_blank
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: ""
    )
    assert_equal "Canned Diced tomatoes", item.display_name_with_brand
  end

  def test_display_name_with_brand_simple_item
    item = ShoppingListItem.new(
      name: "milk",
      brand: "Organic Valley"
    )
    assert_equal "milk (Organic Valley)", item.display_name_with_brand
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

  # Archive functionality tests
  def test_archive_sets_archived_at
    item = shopping_list_items(:one)
    assert_nil item.archived_at

    item.archive!

    assert_not_nil item.archived_at
    assert item.archived?
  end

  def test_archived_scope_returns_only_archived_items
    active_item = shopping_list_items(:one)
    archived_item = shopping_list_items(:two)
    archived_item.update!(archived_at: 1.hour.ago)

    assert_includes ShoppingListItem.active, active_item
    assert_not_includes ShoppingListItem.active, archived_item

    assert_includes ShoppingListItem.archived, archived_item
    assert_not_includes ShoppingListItem.archived, active_item
  end

  def test_default_scope_excludes_archived_items
    active_item = shopping_list_items(:one)
    archived_item = shopping_list_items(:two)
    archived_item.update!(archived_at: 1.hour.ago)

    # Default queries should only return active items
    assert_includes ShoppingListItem.all, active_item
    assert_not_includes ShoppingListItem.all, archived_item
  end

  def test_unscoped_returns_all_items_including_archived
    active_item = shopping_list_items(:one)
    archived_item = shopping_list_items(:two)
    archived_item.update!(archived_at: 1.hour.ago)

    all_items = ShoppingListItem.unscoped.all
    assert_includes all_items, active_item
    assert_includes all_items, archived_item
  end

  def test_archiving_updates_counter_cache
    shopping_list = shopping_lists(:one)
    item = shopping_list.shopping_list_items.create!(name: "Test item")

    initial_count = shopping_list.reload.shopping_list_items_count

    item.archive!

    shopping_list.reload
    assert_equal initial_count - 1, shopping_list.shopping_list_items_count
  end

  def test_archived_items_preserve_all_data
    item = ShoppingListItem.create!(
      name: "tomatoes",
      shopping_list: shopping_lists(:one),
      ingredient_id: ingredients(:one).id,
      packaging_form: "canned",
      preparation_style: "diced"
    )

    item.archive!

    # Reload from database (unscoped to get archived items)
    archived_item = ShoppingListItem.unscoped.find(item.id)

    assert_equal "tomatoes", archived_item.name
    assert_equal ingredients(:one).id, archived_item.ingredient_id
    assert_equal "canned", archived_item.packaging_form
    assert_equal "diced", archived_item.preparation_style
    assert archived_item.archived?
  end

  def test_cannot_archive_already_archived_item
    item = shopping_list_items(:one)
    item.archive!
    first_archived_at = item.archived_at

    # Wait a moment to ensure time difference
    sleep 0.01

    item.archive!

    # archived_at should not change
    assert_equal first_archived_at.to_i, item.archived_at.to_i
  end
end
