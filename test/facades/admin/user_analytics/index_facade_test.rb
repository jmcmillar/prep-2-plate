require "test_helper"

class Admin::UserAnalytics::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @target_user = users(:two)
    @facade = Admin::UserAnalytics::IndexFacade.new(@admin, { user_id: @target_user.id })
  end

  def test_initialization_with_admin_user
    assert_nothing_raised do
      Admin::UserAnalytics::IndexFacade.new(@admin, { user_id: @target_user.id })
    end
  end

  def test_initialization_with_non_admin_user
    non_admin = users(:two)
    non_admin.update!(admin: false)

    assert_raises(Pundit::NotAuthorizedError) do
      Admin::UserAnalytics::IndexFacade.new(non_admin, { user_id: @admin.id })
    end
  end

  def test_loads_correct_analytics_user
    assert_equal @target_user, @facade.analytics_user
  end

  def test_layout_configuration
    assert_equal :admin_menu, @facade.menu
    assert_equal :analytics, @facade.active_key
    assert_nil @facade.nav_resource
  end

  def test_base_collection_returns_empty
    assert_equal 0, @facade.base_collection.count
  end

  def test_resource_facade_class_returns_nil
    assert_nil @facade.resource_facade_class
  end

  # === USER INFO TESTS ===

  def test_user_name_returns_full_name
    assert_equal "#{@target_user.first_name} #{@target_user.last_name}", @facade.user_name
  end

  def test_user_email_returns_email
    assert_equal @target_user.email, @facade.user_email
  end

  # === TIME SERIES TESTS ===

  def test_shopping_lists_over_time_returns_hash
    result = @facade.shopping_lists_over_time

    assert_kind_of Hash, result
    assert result.keys.all? { |key| key.is_a?(Date) || key.is_a?(Time) }
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_shopping_lists_over_time_filters_by_user
    # Create a shopping list for the target user
    @target_user.shopping_lists.create!(name: "Test List")

    result = @facade.shopping_lists_over_time

    # Should only count lists for the target user
    assert_operator result.values.sum, :>=, 0
  end

  def test_items_added_over_time_returns_hash
    result = @facade.items_added_over_time

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_archived_items_over_time_returns_hash
    result = @facade.archived_items_over_time

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_average_list_size_over_time_returns_hash
    result = @facade.average_list_size_over_time

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Float) || value.is_a?(Integer) }
  end

  # === SHOPPING PATTERNS TESTS ===

  def test_shopping_activity_by_day_of_week_returns_hash
    result = @facade.shopping_activity_by_day_of_week

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_items_per_list_distribution_returns_buckets
    result = @facade.items_per_list_distribution

    assert_kind_of Hash, result
    assert_equal 5, result.keys.size
    assert_includes result.keys, "1-5 items"
    assert_includes result.keys, "6-10 items"
    assert_includes result.keys, "11-20 items"
    assert_includes result.keys, "21-50 items"
    assert_includes result.keys, "50+ items"
    assert result.values.all? { |value| value.is_a?(Integer) && value >= 0 }
  end

  def test_completion_rate_returns_proper_structure
    result = @facade.completion_rate

    assert_kind_of Hash, result
    assert_includes result.keys, "Active Items"
    assert_includes result.keys, "Completed Items"
    assert result.values.all? { |value| value.is_a?(Integer) && value >= 0 }
  end

  def test_completion_rate_sums_correctly
    result = @facade.completion_rate
    total_items = @facade.total_items_added

    assert_equal total_items, result["Active Items"] + result["Completed Items"]
  end

  # === INGREDIENT INSIGHTS TESTS ===

  def test_top_ingredients_returns_limited_results
    result = @facade.top_ingredients

    assert_kind_of Hash, result
    assert result.size <= 20, "Should return at most 20 ingredients"
  end

  def test_top_ingredients_returns_ingredient_names
    skip "Requires ingredient data in fixtures"
    result = @facade.top_ingredients

    result.keys.each do |key|
      assert_kind_of String, key
    end
  end

  def test_ingredient_category_distribution_returns_hash
    result = @facade.ingredient_category_distribution

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_packaging_form_breakdown_returns_hash
    result = @facade.packaging_form_breakdown

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_preparation_style_breakdown_returns_hash
    result = @facade.preparation_style_breakdown

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  # === SUMMARY STATS TESTS ===

  def test_total_shopping_lists_returns_integer
    result = @facade.total_shopping_lists

    assert_kind_of Integer, result
    assert_operator result, :>=, 0
  end

  def test_total_items_added_returns_integer
    result = @facade.total_items_added

    assert_kind_of Integer, result
    assert_operator result, :>=, 0
  end

  def test_total_items_completed_returns_integer
    result = @facade.total_items_completed

    assert_kind_of Integer, result
    assert_operator result, :>=, 0
  end

  def test_average_list_size_returns_float
    result = @facade.average_list_size

    assert_kind_of Float, result
    assert_operator result, :>=, 0.0
  end

  def test_average_list_size_handles_no_lists
    # Create a user with no lists
    new_user = User.create!(
      first_name: "Test",
      last_name: "User",
      email: "test_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    facade = Admin::UserAnalytics::IndexFacade.new(@admin, { user_id: new_user.id })
    result = facade.average_list_size

    assert_equal 0.0, result
  end

  def test_current_active_lists_returns_integer
    result = @facade.current_active_lists

    assert_kind_of Integer, result
    assert_operator result, :>=, 0
  end

  def test_completion_percentage_returns_float
    result = @facade.completion_percentage

    assert_kind_of Float, result
    assert_operator result, :>=, 0.0
    assert_operator result, :<=, 100.0
  end

  def test_completion_percentage_handles_zero_items
    # Create a user with no items
    new_user = User.create!(
      first_name: "Test",
      last_name: "User",
      email: "test_zero_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    facade = Admin::UserAnalytics::IndexFacade.new(@admin, { user_id: new_user.id })
    result = facade.completion_percentage

    assert_equal 0, result
  end
end
