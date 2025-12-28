require "test_helper"

class UserIngredientPreferences::ApplyToItemTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @shopping_list = shopping_lists(:one)
  end

  def test_applies_exact_match_preference
    # Create an exact match preference
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Hunt's", item.brand
  end

  def test_applies_packaging_fallback_preference
    # Create a packaging-only preference
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Generic Canned Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Generic Canned Brand", item.brand
  end

  def test_applies_preparation_fallback_preference
    # Create a preparation-only preference
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Diced Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "frozen",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Diced Brand", item.brand
  end

  def test_applies_generic_fallback_preference
    # Create a generic preference (no packaging or prep)
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Generic Brand", item.brand
  end

  def test_returns_false_when_no_preference_exists
    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert_not result
    assert_nil item.brand
  end

  def test_does_not_overwrite_existing_brand
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "User's Choice Brand"
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert_not result
    assert_equal "User's Choice Brand", item.brand
  end

  def test_returns_false_when_ingredient_id_missing
    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: nil,
      name: "tomatoes",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert_not result
    assert_nil item.brand
  end

  def test_returns_false_when_brand_not_blank
    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      brand: "Existing Brand"
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert_not result
    assert_equal "Existing Brand", item.brand
  end

  def test_prefers_exact_match_over_fallbacks
    # Create multiple preferences
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Exact Brand"
    )

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Packaging Brand"
    )

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Exact Brand", item.brand
  end

  def test_prefers_packaging_over_prep_and_generic
    # Create packaging, prep, and generic preferences
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Packaging Brand"
    )

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: "sliced",
      preferred_brand: "Prep Brand"
    )

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "sliced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Packaging Brand", item.brand
  end

  def test_prefers_prep_over_generic
    # Create prep and generic preferences
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Prep Brand"
    )

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "frozen",
      preparation_style: "diced",
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Prep Brand", item.brand
  end

  def test_handles_nil_packaging_and_preparation
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: nil,
      preparation_style: nil,
      brand: nil
    )

    result = UserIngredientPreferences::ApplyToItem.call(item)

    assert result
    assert_equal "Generic Brand", item.brand
  end

  def test_does_not_save_item
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    )

    item = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    UserIngredientPreferences::ApplyToItem.call(item)

    # Item should not be persisted
    assert item.new_record?
    assert_equal "Hunt's", item.brand
  end

  def test_works_with_different_users
    user_two = users(:two)
    shopping_list_two = ShoppingList.create!(user: user_two, name: "User Two's List")

    # Create preferences for both users
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "User One Brand"
    )

    UserIngredientPreference.create!(
      user: user_two,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "User Two Brand"
    )

    # Test with user one's item
    item_one = ShoppingListItem.new(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    UserIngredientPreferences::ApplyToItem.call(item_one)
    assert_equal "User One Brand", item_one.brand

    # Test with user two's item
    item_two = ShoppingListItem.new(
      shopping_list: shopping_list_two,
      ingredient: @ingredient,
      name: "tomatoes",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: nil
    )

    UserIngredientPreferences::ApplyToItem.call(item_two)
    assert_equal "User Two Brand", item_two.brand
  end
end
