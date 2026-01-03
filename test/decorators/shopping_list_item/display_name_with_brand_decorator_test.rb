require "test_helper"

class ShoppingListItem::DisplayNameWithBrandDecoratorTest < ActiveSupport::TestCase
  def test_display_name_with_brand_when_brand_present
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "Hunts"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "canned diced tomatoes (Hunts)", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_when_brand_blank
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: ""
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "canned diced tomatoes", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_when_brand_nil
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "canned diced tomatoes", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_simple_name_no_brand
    item = ShoppingListItem.new(name: "tomatoes")
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "tomatoes", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_simple_name_with_brand
    item = ShoppingListItem.new(name: "tomatoes", brand: "Hunts")
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "tomatoes (Hunts)", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_with_only_packaging_form
    item = ShoppingListItem.new(
      name: "beans",
      packaging_form: "canned",
      brand: "Bush's"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "canned beans (Bush's)", decorated.display_name_with_brand
  end

  def test_display_name_with_brand_with_only_preparation_style
    item = ShoppingListItem.new(
      name: "carrots",
      preparation_style: "diced",
      brand: "Green Giant"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "diced carrots (Green Giant)", decorated.display_name_with_brand
  end

  def test_inherits_display_name_from_parent_decorator
    item = ShoppingListItem.new(
      name: "Tomatoes",
      packaging_form: "frozen",
      preparation_style: "chopped"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)

    # Should inherit the downcasing behavior from parent
    assert_equal "frozen chopped tomatoes", decorated.display_name
    refute_match(/[A-Z]/, decorated.display_name, "Display name should not contain uppercase letters")
  end

  def test_decorate_collection
    items = [
      ShoppingListItem.new(name: "tomatoes", brand: "Hunts"),
      ShoppingListItem.new(name: "beans", packaging_form: "canned", brand: "Bush's"),
      ShoppingListItem.new(name: "carrots", preparation_style: "diced")
    ]

    decorated_collection = ShoppingListItem::DisplayNameWithBrandDecorator.decorate_collection(items)

    assert_equal 3, decorated_collection.size
    assert_equal "tomatoes (Hunts)", decorated_collection[0].display_name_with_brand
    assert_equal "canned beans (Bush's)", decorated_collection[1].display_name_with_brand
    assert_equal "diced carrots", decorated_collection[2].display_name_with_brand
  end

  def test_delegates_to_underlying_shopping_list_item
    item = ShoppingListItem.new(
      name: "tomatoes",
      packaging_form: "canned",
      brand: "Hunts"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)

    # Should delegate methods to the underlying item
    assert_equal "tomatoes", decorated.name
    assert_equal "canned", decorated.packaging_form
    assert_equal "Hunts", decorated.brand
  end

  def test_original_object_returns_unwrapped_item
    item = ShoppingListItem.new(name: "tomatoes", brand: "Hunts")
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)

    assert_equal item, decorated.original_object
  end

  def test_brand_with_special_characters
    item = ShoppingListItem.new(
      name: "tomatoes",
      brand: "Hunt's®"
    )
    decorated = ShoppingListItem::DisplayNameWithBrandDecorator.decorate(item)
    assert_equal "tomatoes (Hunt's®)", decorated.display_name_with_brand
  end
end
