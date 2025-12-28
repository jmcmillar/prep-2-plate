require "test_helper"

class UserIngredientPreferenceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @ingredient = ingredients(:one)
    @preference = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Swanson"
    )
  end

  # Association Tests
  def test_belongs_to_user
    assert_respond_to @preference, :user
    assert_instance_of User, @preference.user
  end

  def test_belongs_to_ingredient
    assert_respond_to @preference, :ingredient
    assert_instance_of Ingredient, @preference.ingredient
  end

  # Validation Tests - Presence
  def test_user_required
    preference = UserIngredientPreference.new(user: nil, ingredient: @ingredient, preferred_brand: "Brand")
    assert_not preference.valid?
    assert_includes preference.errors[:user], "must exist"
  end

  def test_ingredient_required
    preference = UserIngredientPreference.new(user: @user, ingredient: nil, preferred_brand: "Brand")
    assert_not preference.valid?
    assert_includes preference.errors[:ingredient], "must exist"
  end

  def test_preferred_brand_required
    preference = UserIngredientPreference.new(user: @user, ingredient: @ingredient, preferred_brand: nil)
    assert_not preference.valid?
    assert_includes preference.errors[:preferred_brand], "can't be blank"
  end

  def test_preferred_brand_cannot_be_blank
    preference = UserIngredientPreference.new(user: @user, ingredient: @ingredient, preferred_brand: "")
    assert_not preference.valid?
    assert_includes preference.errors[:preferred_brand], "can't be blank"
  end

  # Validation Tests - Uniqueness
  def test_uniqueness_of_user_ingredient_packaging_prep_combination
    # Create first preference
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    )

    # Try to create duplicate
    duplicate = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand B"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  def test_allows_same_ingredient_with_different_packaging
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    )

    different_packaging = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "frozen",
      preparation_style: "diced",
      preferred_brand: "Brand B"
    )

    assert different_packaging.valid?
  end

  def test_allows_same_ingredient_with_different_preparation
    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    )

    different_prep = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "crushed",
      preferred_brand: "Brand B"
    )

    assert different_prep.valid?
  end

  def test_allows_different_users_same_preference
    other_user = users(:two)

    UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    )

    different_user = UserIngredientPreference.new(
      user: other_user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand A"
    )

    assert different_user.valid?
  end

  # Validation Tests - Inclusion
  def test_packaging_form_must_be_valid_or_nil
    valid_forms = Ingredient::PACKAGING_FORMS.keys.map(&:to_s)

    valid_forms.each do |form|
      preference = UserIngredientPreference.new(
        user: @user,
        ingredient: @ingredient,
        packaging_form: form,
        preferred_brand: "Brand"
      )
      assert preference.valid?, "#{form} should be valid"
    end
  end

  def test_packaging_form_allows_nil
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preferred_brand: "Brand"
    )
    assert preference.valid?
  end

  def test_packaging_form_rejects_invalid_values
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "invalid_form",
      preferred_brand: "Brand"
    )
    assert_not preference.valid?
    assert_includes preference.errors[:packaging_form], "is not included in the list"
  end

  def test_preparation_style_must_be_valid_or_nil
    valid_styles = Ingredient::PREPARATION_STYLES.keys.map(&:to_s)

    valid_styles.each do |style|
      preference = UserIngredientPreference.new(
        user: @user,
        ingredient: @ingredient,
        preparation_style: style,
        preferred_brand: "Brand"
      )
      assert preference.valid?, "#{style} should be valid"
    end
  end

  def test_preparation_style_allows_nil
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      preparation_style: nil,
      preferred_brand: "Brand"
    )
    assert preference.valid?
  end

  def test_preparation_style_rejects_invalid_values
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: @ingredient,
      preparation_style: "invalid_style",
      preferred_brand: "Brand"
    )
    assert_not preference.valid?
    assert_includes preference.errors[:preparation_style], "is not included in the list"
  end

  # Default Values Tests
  def test_usage_count_defaults_to_one
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      preferred_brand: "Brand"
    )
    assert_equal 1, preference.usage_count
  end

  def test_last_used_at_set_on_create
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      preferred_brand: "Brand"
    )
    assert_not_nil preference.last_used_at
    assert_in_delta Time.current, preference.last_used_at, 2.seconds
  end

  # Scope Tests
  def test_for_user_scope
    user_two = users(:two)
    pref1 = UserIngredientPreference.create!(user: @user, ingredient: @ingredient, preferred_brand: "Brand A")
    pref2 = UserIngredientPreference.create!(user: user_two, ingredient: @ingredient, preferred_brand: "Brand B")

    results = UserIngredientPreference.for_user(@user)
    assert_includes results, pref1
    assert_not_includes results, pref2
  end

  def test_for_ingredient_scope
    ingredient_two = ingredients(:two)
    ingredient_three = ingredients(:three)
    pref1 = UserIngredientPreference.create!(user: @user, ingredient: ingredient_three, preferred_brand: "Brand A", packaging_form: "canned")
    pref2 = UserIngredientPreference.create!(user: @user, ingredient: ingredient_two, preferred_brand: "Brand B", packaging_form: "canned")

    results = UserIngredientPreference.for_ingredient(ingredient_three)
    assert_includes results, pref1
    assert_not_includes results, pref2
  end

  def test_most_used_scope
    pref1 = UserIngredientPreference.create!(user: @user, ingredient: @ingredient, preferred_brand: "Brand A", usage_count: 100, packaging_form: "frozen")
    pref2 = UserIngredientPreference.create!(user: @user, ingredient: ingredients(:two), preferred_brand: "Brand B", usage_count: 50, packaging_form: "dried")
    pref3 = UserIngredientPreference.create!(user: @user, ingredient: ingredients(:three), preferred_brand: "Brand C", usage_count: 150, packaging_form: "canned")

    results = UserIngredientPreference.most_used.limit(3)
    assert_equal pref3, results[0]
    assert_equal pref1, results[1]
    assert_equal pref2, results[2]
  end

  def test_recently_used_scope
    # Clear existing preferences to avoid fixture interference
    UserIngredientPreference.destroy_all

    travel_to 3.days.ago do
      @old_pref = UserIngredientPreference.create!(user: @user, ingredient: @ingredient, preferred_brand: "Brand A", packaging_form: "frozen")
    end

    @new_pref = UserIngredientPreference.create!(user: @user, ingredient: ingredients(:two), preferred_brand: "Brand B", packaging_form: "dried")

    results = UserIngredientPreference.recently_used
    assert_equal @new_pref, results.first
    assert_equal @old_pref, results.last
  end

  def test_matching_scope_exact_match
    exact = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Exact Brand"
    )

    results = UserIngredientPreference.matching(@ingredient.id, "canned", "diced")
    assert_includes results, exact
  end

  def test_matching_scope_packaging_match
    packaging_match = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Packaging Brand"
    )

    results = UserIngredientPreference.matching(@ingredient.id, "canned", nil)
    assert_includes results, packaging_match
  end

  def test_matching_scope_preparation_match
    prep_match = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Prep Brand"
    )

    results = UserIngredientPreference.matching(@ingredient.id, nil, "diced")
    assert_includes results, prep_match
  end

  def test_matching_scope_generic_match
    generic = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    results = UserIngredientPreference.matching(@ingredient.id, nil, nil)
    assert_includes results, generic
  end

  # find_best_match Tests
  def test_find_best_match_exact_match
    exact = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Exact Brand"
    )

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_equal exact, result
  end

  def test_find_best_match_packaging_fallback
    packaging = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Packaging Brand"
    )

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_equal packaging, result
  end

  def test_find_best_match_preparation_fallback
    prep = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Prep Brand"
    )

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_equal prep, result
  end

  def test_find_best_match_generic_fallback
    generic = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Generic Brand"
    )

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_equal generic, result
  end

  def test_find_best_match_returns_nil_when_no_match
    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_nil result
  end

  def test_find_best_match_prefers_exact_over_fallbacks
    exact = UserIngredientPreference.create!(
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

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "diced")
    assert_equal exact, result
  end

  def test_find_best_match_prefers_packaging_over_prep_and_generic
    packaging = UserIngredientPreference.create!(
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

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "canned", "sliced")
    assert_equal packaging, result
  end

  def test_find_best_match_prefers_prep_over_generic
    prep = UserIngredientPreference.create!(
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

    result = UserIngredientPreference.find_best_match(@user.id, @ingredient.id, "frozen", "diced")
    assert_equal prep, result
  end

  # record_usage! Tests
  def test_record_usage_increments_usage_count
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      preferred_brand: "Brand",
      usage_count: 5
    )

    preference.record_usage!
    assert_equal 6, preference.reload.usage_count
  end

  def test_record_usage_updates_last_used_at
    preference = UserIngredientPreference.create!(
      user: @user,
      ingredient: @ingredient,
      preferred_brand: "Brand"
    )

    old_time = preference.last_used_at
    travel 1.day

    preference.record_usage!
    assert_operator preference.reload.last_used_at, :>, old_time
  end

  # display_context Tests
  def test_display_context_with_packaging_and_prep
    canned_tomatoes = ingredients(:canned_tomatoes)
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: canned_tomatoes,
      packaging_form: "canned",
      preparation_style: "diced",
      preferred_brand: "Brand"
    )

    assert_equal "Canned Diced tomatoes", preference.display_context
  end

  def test_display_context_with_only_packaging
    # Create a fresh ingredient for this test
    ingredient = Ingredient.create!(name: "broth", packaging_form: "canned")
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: ingredient,
      packaging_form: "canned",
      preparation_style: nil,
      preferred_brand: "Brand"
    )

    assert_equal "Canned broth", preference.display_context
  end

  def test_display_context_with_only_prep
    # Create a fresh ingredient for this test
    ingredient = Ingredient.create!(name: "onions_test", preparation_style: "diced")
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: ingredient,
      packaging_form: nil,
      preparation_style: "diced",
      preferred_brand: "Brand"
    )

    assert_equal "Diced onions_test", preference.display_context
  end

  def test_display_context_generic
    # Create a fresh ingredient for this test
    ingredient = Ingredient.create!(name: "generic_ingredient")
    preference = UserIngredientPreference.new(
      user: @user,
      ingredient: ingredient,
      packaging_form: nil,
      preparation_style: nil,
      preferred_brand: "Brand"
    )

    assert_equal "generic_ingredient", preference.display_context
  end

  def test_ransackable_attributes
    expected_attributes = ["user_id", "ingredient_id", "packaging_form", "preparation_style", "preferred_brand"]
    expected_attributes.each do |attr|
      assert_includes UserIngredientPreference.ransackable_attributes, attr
    end
  end

  def test_ransackable_associations
    expected_associations = ["user", "ingredient"]
    expected_associations.each do |assoc|
      assert_includes UserIngredientPreference.ransackable_associations, assoc
    end
  end
end
