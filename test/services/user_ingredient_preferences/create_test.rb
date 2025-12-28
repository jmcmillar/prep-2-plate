require "test_helper"

class UserIngredientPreferences::CreateTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
  end

  def test_creates_new_preference
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    }

    assert_difference "UserIngredientPreference.count", 1 do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end

    preference = UserIngredientPreference.last
    assert_equal @user, preference.user
    assert_equal @ingredient, preference.ingredient
    assert_equal "canned", preference.packaging_form
    assert_equal "diced", preference.preparation_style
    assert_equal "Hunt's", preference.preferred_brand
    assert_equal 1, preference.usage_count
  end

  def test_updates_existing_preference
    existing = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Old Brand",
      usage_count: 5
    )

    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "New Brand"
    }

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end

    existing.reload
    assert_equal "New Brand", existing.preferred_brand
    assert_equal 6, existing.usage_count
  end

  def test_records_usage_on_update
    existing = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A",
      usage_count: 3
    )

    old_last_used = existing.last_used_at
    travel 1.hour

    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    }

    UserIngredientPreferences::Create.call(params)

    existing.reload
    assert_equal 4, existing.usage_count
    assert_operator existing.last_used_at, :>, old_last_used
  end

  def test_handles_nil_packaging_and_preparation
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    }

    assert_difference "UserIngredientPreference.count", 1 do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end

    preference = UserIngredientPreference.last
    assert_nil preference.packaging_form
    assert_nil preference.preparation_style
  end

  def test_handles_blank_packaging_and_preparation
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "",
      preparation_style: "",
      preferred_brand: "Generic Brand"
    }

    assert_difference "UserIngredientPreference.count", 1 do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end

    preference = UserIngredientPreference.last
    # Blank strings should be stored as nil or blank based on model normalization
    assert_includes [nil, ""], preference.packaging_form
    assert_includes [nil, ""], preference.preparation_style
  end

  def test_returns_false_on_validation_error
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: nil  # Invalid - brand is required
    }

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Create.call(params)
      assert_not result
    end
  end

  def test_returns_false_when_user_id_missing
    params = {
      user_id: nil,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand"
    }

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Create.call(params)
      assert_not result
    end
  end

  def test_returns_false_when_ingredient_id_missing
    params = {
      user_id: @user.id,
      ingredient_id: nil,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand"
    }

    assert_no_difference "UserIngredientPreference.count" do
      result = UserIngredientPreferences::Create.call(params)
      assert_not result
    end
  end

  def test_creates_different_preferences_for_different_packaging
    # Clear existing preferences to avoid fixture interference
    UserIngredientPreference.where(user: @user, ingredient: @ingredient).destroy_all

    params1 = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Canned Brand"
    }

    params2 = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "frozen",
      preparation_style: nil,
      preferred_brand: "Frozen Brand"
    }

    assert_difference "UserIngredientPreference.count", 2 do
      UserIngredientPreferences::Create.call(params1)
      UserIngredientPreferences::Create.call(params2)
    end

    canned = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, packaging_form: "canned")
    frozen = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, packaging_form: "frozen")

    assert_equal "Canned Brand", canned.preferred_brand
    assert_equal "Frozen Brand", frozen.preferred_brand
  end

  def test_creates_different_preferences_for_different_preparation
    # Clear existing preferences to avoid fixture interference
    UserIngredientPreference.where(user: @user, ingredient: @ingredient).destroy_all

    params1 = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Diced Brand"
    }

    params2 = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: nil,
      preparation_style: "crushed",
      preferred_brand: "Crushed Brand"
    }

    assert_difference "UserIngredientPreference.count", 2 do
      UserIngredientPreferences::Create.call(params1)
      UserIngredientPreferences::Create.call(params2)
    end

    diced = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, preparation_style: "diced")
    crushed = UserIngredientPreference.find_by(user: @user, ingredient: @ingredient, preparation_style: "crushed")

    assert_equal "Diced Brand", diced.preferred_brand
    assert_equal "Crushed Brand", crushed.preferred_brand
  end

  def test_works_with_different_users
    user_two = users(:two)

    # Clear existing preferences to avoid fixture interference
    UserIngredientPreference.where(user: @user, ingredient: @ingredient).destroy_all
    UserIngredientPreference.where(user: user_two, ingredient: @ingredient).destroy_all

    params1 = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "User One Brand"
    }

    params2 = {
      user_id: user_two.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "User Two Brand"
    }

    assert_difference "UserIngredientPreference.count", 2 do
      UserIngredientPreferences::Create.call(params1)
      UserIngredientPreferences::Create.call(params2)
    end

    user_one_pref = UserIngredientPreference.find_by(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced"
    )
    user_two_pref = UserIngredientPreference.find_by(
      user: user_two,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced"
    )

    assert_equal "User One Brand", user_one_pref.preferred_brand
    assert_equal "User Two Brand", user_two_pref.preferred_brand
  end

  def test_accepts_string_keys
    params = {
      "user_id" => @user.id,
      "ingredient_id" => @ingredient.id,
      "packaging_form" => "canned",
      "preparation_style" => "diced",
      "preferred_brand" => "Hunt's"
    }

    assert_difference "UserIngredientPreference.count", 1 do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end
  end

  def test_accepts_symbol_keys
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    }

    assert_difference "UserIngredientPreference.count", 1 do
      result = UserIngredientPreferences::Create.call(params)
      assert result
    end
  end

  def test_returns_preference_object_on_success
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Hunt's"
    }

    result = UserIngredientPreferences::Create.call(params)

    assert_instance_of UserIngredientPreference, result
    assert_equal "Hunt's", result.preferred_brand
  end

  def test_returns_false_on_failure
    params = {
      user_id: @user.id,
      ingredient_id: @ingredient.id,
      packaging_form: "invalid_packaging",
      preparation_style: "diced",
      preferred_brand: "Brand"
    }

    result = UserIngredientPreferences::Create.call(params)

    assert_equal false, result
  end
end
