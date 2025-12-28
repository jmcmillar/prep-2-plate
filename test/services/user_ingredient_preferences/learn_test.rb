require "test_helper"

class UserIngredientPreferences::LearnTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @shopping_list = shopping_lists(:one)
  end

  def test_creates_new_preference_when_none_exists
    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "Hunt's"
    )

    assert_difference "UserIngredientPreference.count", 1 do
      UserIngredientPreferences::Learn.call(item)
    end

    preference = UserIngredientPreference.last
    assert_equal @user, preference.user
    assert_equal @ingredient, preference.ingredient
    assert_equal "canned", preference.packaging_form
    assert_equal "diced", preference.preparation_style
    assert_equal "Hunt's", preference.preferred_brand
    assert_equal 1, preference.usage_count
  end

  def test_increments_usage_count_when_preference_exists
    existing_pref = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's",
      usage_count: 5
    )

    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "Hunt's"
    )

    assert_no_difference "UserIngredientPreference.count" do
      UserIngredientPreferences::Learn.call(item)
    end

    assert_equal 6, existing_pref.reload.usage_count
  end

  def test_returns_false_when_ingredient_id_missing
    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: nil,
      name: "test ingredient",
      brand: "Hunt's"
    )

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Learn.call(item)
      assert_not result
    end
  end

  def test_returns_false_when_brand_missing
    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      brand: nil
    )

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Learn.call(item)
      assert_not result
    end
  end

  def test_returns_false_when_brand_blank
    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      brand: ""
    )

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Learn.call(item)
      assert_not result
    end
  end

  def test_creates_separate_preferences_for_different_packaging
    item1 = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: "canned",
      brand: "Hunt's"
    )

    item2 = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: "frozen",
      brand: "Birds Eye"
    )

    assert_difference "UserIngredientPreference.count", 2 do
      UserIngredientPreferences::Learn.call(item1)
      UserIngredientPreferences::Learn.call(item2)
    end

    canned_pref = UserIngredientPreference.find_by(packaging_form: "canned")
    frozen_pref = UserIngredientPreference.find_by(packaging_form: "frozen")

    assert_equal "Hunt's", canned_pref.preferred_brand
    assert_equal "Birds Eye", frozen_pref.preferred_brand
  end

  def test_creates_separate_preferences_for_different_preparation
    # Clear existing preferences to avoid fixture interference
    UserIngredientPreference.where(user: @user, ingredient: @ingredient).destroy_all

    item1 = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      preparation_style: "diced",
      brand: "Brand A"
    )

    item2 = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      preparation_style: "crushed",
      brand: "Brand B"
    )

    assert_difference "UserIngredientPreference.count", 2 do
      UserIngredientPreferences::Learn.call(item1)
      UserIngredientPreferences::Learn.call(item2)
    end

    diced_pref = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, preparation_style: "diced")
    crushed_pref = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, preparation_style: "crushed")

    assert_equal "Brand A", diced_pref.preferred_brand
    assert_equal "Brand B", crushed_pref.preferred_brand
  end

  def test_handles_nil_packaging_and_preparation
    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: nil,
      preparation_style: nil,
      brand: "Generic Brand"
    )

    assert_difference "UserIngredientPreference.count", 1 do
      UserIngredientPreferences::Learn.call(item)
    end

    preference = UserIngredientPreference.last
    assert_nil preference.packaging_form
    assert_nil preference.preparation_style
    assert_equal "Generic Brand", preference.preferred_brand
  end

  def test_updates_last_used_at_when_preference_exists
    existing_pref = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    )

    old_time = existing_pref.last_used_at
    travel 1.hour

    item = ShoppingListItem.create!(
      shopping_list: @shopping_list,
      ingredient: @ingredient,
      name: "test ingredient",
      packaging_form: "canned",
      preparation_style: "diced",
      brand: "Hunt's"
    )

    UserIngredientPreferences::Learn.call(item)

    assert_operator existing_pref.reload.last_used_at, :>, old_time
  end

end
