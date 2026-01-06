require "test_helper"

class Admin::Analytics::ShoppingListsFacadeTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @facade = Admin::Analytics::ShoppingListsFacade.new(@admin, {})
  end

  def test_initialization_with_admin_user
    assert_nothing_raised do
      Admin::Analytics::ShoppingListsFacade.new(@admin, {})
    end
  end

  def test_initialization_with_non_admin_user
    non_admin = users(:two)
    non_admin.update!(admin: false)

    assert_raises(Pundit::NotAuthorizedError) do
      Admin::Analytics::ShoppingListsFacade.new(non_admin, {})
    end
  end

  def test_layout_configuration
    assert_equal :admin_menu, @facade.menu
    assert_equal :analytics, @facade.active_key
    assert_nil @facade.nav_resource
  end

  def test_shopping_lists_over_time_returns_hash
    result = @facade.shopping_lists_over_time

    assert_kind_of Hash, result
    assert result.keys.all? { |key| key.is_a?(Date) || key.is_a?(Time) }
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_shopping_lists_over_time_counts_lists
    result = @facade.shopping_lists_over_time

    # Should have some data from fixtures
    assert result.values.sum > 0, "Expected at least one shopping list to be counted"
  end

  def test_items_added_over_time_returns_hash
    result = @facade.items_added_over_time

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_items_added_over_time_counts_all_items
    result = @facade.items_added_over_time

    # Should include both archived and active items
    assert result.values.sum > 0, "Expected at least one item to be counted"
  end

  def test_archived_items_over_time_returns_hash
    result = @facade.archived_items_over_time

    assert_kind_of Hash, result
    assert result.values.all? { |value| value.is_a?(Integer) }
  end

  def test_archived_items_over_time_only_counts_archived
    # Create an archived item to ensure we have data
    archived_count = ShoppingListItem.unscoped.where.not(archived_at: nil).count
    result = @facade.archived_items_over_time

    assert_equal archived_count, result.values.sum
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

  def test_top_ingredients_returns_limited_results
    result = @facade.top_ingredients

    assert_kind_of Hash, result
    assert result.size <= 20, "Should return at most 20 ingredients"
    assert result.values.all? { |value| value.is_a?(Integer) && value > 0 }
  end

  def test_top_ingredients_returns_ingredient_names
    result = @facade.top_ingredients

    result.keys.each do |key|
      assert_kind_of String, key
    end
  end

  def test_packaging_form_breakdown_returns_titleized_keys
    result = @facade.packaging_form_breakdown

    assert_kind_of Hash, result
    # Check that keys are titleized (e.g., "Fresh" not "fresh")
    result.keys.each do |key|
      assert_equal key, key.titleize, "Expected titleized keys"
    end
  end

  def test_packaging_form_breakdown_excludes_nil_values
    result = @facade.packaging_form_breakdown

    # Should not include items without packaging_form
    custom_item = shopping_list_items(:custom_item)
    assert_nil custom_item.packaging_form

    # The count should only include items with packaging_form
    total_with_packaging = ShoppingListItem.unscoped.where.not(packaging_form: nil).count
    assert_equal total_with_packaging, result.values.sum
  end

  def test_preparation_style_breakdown_returns_titleized_keys
    result = @facade.preparation_style_breakdown

    assert_kind_of Hash, result
    result.keys.each do |key|
      assert_equal key, key.titleize, "Expected titleized keys"
    end
  end

  def test_preparation_style_breakdown_excludes_nil_values
    result = @facade.preparation_style_breakdown

    # Should not include items without preparation_style
    total_with_preparation = ShoppingListItem.unscoped.where.not(preparation_style: nil).count
    assert_equal total_with_preparation, result.values.sum
  end

  def test_ingredient_category_distribution_returns_categories
    result = @facade.ingredient_category_distribution

    assert_kind_of Hash, result
    result.keys.each do |key|
      assert_kind_of String, key
    end
  end

  def test_ingredient_category_distribution_only_includes_categorized_items
    result = @facade.ingredient_category_distribution

    # Should only count items that have both ingredient and ingredient_category
    expected_count = ShoppingListItem.unscoped
                                     .joins(ingredient: :ingredient_category)
                                     .count
    assert_equal expected_count, result.values.sum
  end

  def test_archive_rate_by_day_of_week_returns_all_days
    result = @facade.archive_rate_by_day_of_week

    assert_kind_of Hash, result
    assert_equal 7, result.keys.size

    days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    days.each do |day|
      assert_includes result.keys, day
      assert result[day].is_a?(Integer) && result[day] >= 0
    end
  end

  def test_archive_rate_by_day_of_week_maintains_order
    result = @facade.archive_rate_by_day_of_week

    expected_order = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    assert_equal expected_order, result.keys
  end

  def test_active_vs_archived_items_returns_both_counts
    result = @facade.active_vs_archived_items

    assert_kind_of Hash, result
    assert_includes result.keys, "Active Items"
    assert_includes result.keys, "Archived Items"

    active_count = ShoppingListItem.count
    archived_count = ShoppingListItem.unscoped.where.not(archived_at: nil).count

    assert_equal active_count, result["Active Items"]
    assert_equal archived_count, result["Archived Items"]
  end

  def test_average_items_per_list_returns_single_entry
    result = @facade.average_items_per_list

    assert_kind_of Hash, result
    assert_includes result.keys, "Average Items per List"
    assert result["Average Items per List"].is_a?(Float)
  end

  def test_average_items_per_list_calculates_correctly
    total_lists = ShoppingList.count
    total_items = ShoppingListItem.unscoped.count
    expected_average = (total_items.to_f / total_lists).round(1)

    result = @facade.average_items_per_list

    assert_equal expected_average, result["Average Items per List"]
  end

  def test_average_items_per_list_with_no_lists
    # Clear all shopping lists
    ShoppingList.destroy_all

    result = @facade.average_items_per_list

    assert_equal({}, result)
  end
end
