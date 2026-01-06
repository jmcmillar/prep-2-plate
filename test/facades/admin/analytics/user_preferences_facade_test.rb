require "test_helper"

class Admin::Analytics::UserPreferencesFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @facade = Admin::Analytics::UserPreferencesFacade.new(@admin, {})
  end

  def test_initialization_with_admin_user
    assert_nothing_raised do
      Admin::Analytics::UserPreferencesFacade.new(@admin, {})
    end
  end

  def test_initialization_with_non_admin_user
    non_admin = users(:two)
    non_admin.update!(admin: false)

    assert_raises(Pundit::NotAuthorizedError) do
      Admin::Analytics::UserPreferencesFacade.new(non_admin, {})
    end
  end

  def test_layout_configuration
    assert_equal :admin_menu, @facade.menu
    assert_equal :analytics, @facade.active_key
    assert_nil @facade.nav_resource
  end

  def test_top_brands_by_usage_returns_hash
    result = @facade.top_brands_by_usage

    assert_kind_of Hash, result
    assert result.size <= 20, "Should return at most 20 brands"
  end

  def test_top_brands_by_usage_excludes_nil_brands
    result = @facade.top_brands_by_usage

    # Should not include preferences without a brand
    assert_not_includes result.keys, nil
    result.keys.each do |brand|
      assert_kind_of String, brand
    end
  end

  def test_top_brands_by_usage_sorted_descending
    result = @facade.top_brands_by_usage

    # Check that values are in descending order
    values = result.values
    assert_equal values, values.sort.reverse
  end

  def test_top_brands_by_usage_sums_usage_count
    result = @facade.top_brands_by_usage

    # Verify that the counts are integers
    result.values.each do |count|
      assert_kind_of Integer, count
      assert count > 0
    end
  end

  def test_preferences_learned_over_time_returns_hash
    result = @facade.preferences_learned_over_time

    assert_kind_of Hash, result
    assert result.keys.all? { |key| key.is_a?(Date) || key.is_a?(Time) }
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_brand_preferences_by_category_returns_nested_hash
    result = @facade.brand_preferences_by_category

    assert_kind_of Hash, result

    result.each do |category, brands|
      assert_kind_of String, category
      assert_kind_of Hash, brands

      brands.each do |brand, count|
        assert_kind_of String, brand
        assert_kind_of Integer, count
      end
    end
  end

  def test_brand_preferences_by_category_limits_brands_per_category
    result = @facade.brand_preferences_by_category

    result.each do |_category, brands|
      assert brands.size <= 5, "Should return at most 5 brands per category"
    end
  end

  def test_brand_preferences_by_category_excludes_nil_brands
    result = @facade.brand_preferences_by_category

    result.each do |_category, brands|
      assert_not_includes brands.keys, nil
    end
  end

  def test_packaging_preferences_distribution_returns_titleized_keys
    result = @facade.packaging_preferences_distribution

    assert_kind_of Hash, result
    result.keys.each do |key|
      assert_equal key, key.titleize, "Expected titleized keys"
    end
  end

  def test_packaging_preferences_distribution_excludes_nil
    result = @facade.packaging_preferences_distribution

    # Verify no nil keys
    assert_not_includes result.keys, nil

    # Verify counts match preferences with packaging_form
    total = UserIngredientPreference.where.not(packaging_form: nil).sum(:usage_count)
    assert_equal total, result.values.sum
  end

  def test_preparation_preferences_distribution_returns_titleized_keys
    result = @facade.preparation_preferences_distribution

    assert_kind_of Hash, result
    result.keys.each do |key|
      assert_equal key, key.titleize, "Expected titleized keys"
    end
  end

  def test_preparation_preferences_distribution_excludes_nil
    result = @facade.preparation_preferences_distribution

    assert_not_includes result.keys, nil

    total = UserIngredientPreference.where.not(preparation_style: nil).sum(:usage_count)
    assert_equal total, result.values.sum
  end

  def test_preference_usage_distribution_returns_five_buckets
    result = @facade.preference_usage_distribution

    assert_kind_of Hash, result
    assert_equal 5, result.keys.size

    expected_keys = [
      "Used 1 time",
      "Used 2-5 times",
      "Used 6-10 times",
      "Used 11-20 times",
      "Used 20+ times"
    ]

    expected_keys.each do |key|
      assert_includes result.keys, key
      assert result[key].is_a?(Integer) && result[key] >= 0
    end
  end

  def test_preference_usage_distribution_categorizes_correctly
    # Create a known preference with specific usage count
    test_user = users(:two)
    test_ingredient = ingredients(:one)

    pref = UserIngredientPreference.create!(
      user: test_user,
      ingredient: test_ingredient,
      usage_count: 15,
      last_used_at: Time.current
    )

    result = @facade.preference_usage_distribution

    # This preference should be in the "Used 11-20 times" bucket
    assert result["Used 11-20 times"] > 0

    pref.destroy
  end

  def test_preferences_by_user_returns_distribution
    result = @facade.preferences_by_user

    assert_kind_of Hash, result

    expected_keys = [
      "0 preferences",
      "1-5 preferences",
      "6-10 preferences",
      "11-20 preferences",
      "20+ preferences"
    ]

    expected_keys.each do |key|
      assert_includes result.keys, key
      assert result[key].is_a?(Integer) && result[key] >= 0
    end
  end

  def test_preferences_by_user_counts_users_without_preferences
    # Count users without any preferences
    users_without_prefs = User.left_joins(:user_ingredient_preferences)
                              .where(user_ingredient_preferences: { id: nil })
                              .count

    result = @facade.preferences_by_user

    assert_equal users_without_prefs, result["0 preferences"]
  end

  def test_most_active_users_returns_limited_results
    result = @facade.most_active_users

    assert_kind_of Hash, result
    assert result.size <= 10, "Should return at most 10 users"
  end

  def test_most_active_users_sorted_descending
    result = @facade.most_active_users

    values = result.values
    assert_equal values, values.sort.reverse, "Should be sorted by usage count descending"
  end

  def test_most_active_users_returns_email_keys
    result = @facade.most_active_users

    result.keys.each do |email|
      assert_kind_of String, email
      assert_match(/@/, email, "Keys should be email addresses")
    end
  end

  def test_preference_retention_returns_four_time_periods
    result = @facade.preference_retention

    assert_kind_of Hash, result
    assert_equal 4, result.keys.size

    expected_keys = [
      "Used in last 30 days",
      "Used 30-60 days ago",
      "Used 60-90 days ago",
      "Used 90+ days ago"
    ]

    expected_keys.each do |key|
      assert_includes result.keys, key
      assert result[key].is_a?(Integer) && result[key] >= 0
    end
  end

  def test_preference_retention_categorizes_correctly
    result = @facade.preference_retention

    # Verify total adds up to all preferences
    total = UserIngredientPreference.count
    assert_equal total, result.values.sum
  end

  def test_preference_retention_with_old_preference
    # Verify our fixture with 95 days ago is counted
    old_pref = user_ingredient_preferences(:old_preference)
    assert old_pref.last_used_at < 90.days.ago

    result = @facade.preference_retention

    assert result["Used 90+ days ago"] > 0
  end

  def test_preference_retention_with_recent_preference
    result = @facade.preference_retention

    # At least one preference should be in the last 30 days from fixtures
    assert result["Used in last 30 days"] > 0
  end
end
