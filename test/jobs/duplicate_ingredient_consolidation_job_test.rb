require "test_helper"

class DuplicateIngredientConsolidationJobTest < ActiveJob::TestCase
  def test_consolidates_duplicate_ingredients_keeping_oldest
    # Setup: Create canonical (oldest) and duplicate using insert to bypass unique constraint
    canonical_id = create_ingredient_bypassing_validation(name: "tomato", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "tomato", created_at: 1.day.ago)

    DuplicateIngredientConsolidationJob.perform_now

    assert_not_nil Ingredient.find_by(id: canonical_id)
    assert_nil Ingredient.find_by(id: duplicate_id)
  end

  def test_migrates_recipe_ingredients_to_canonical
    canonical_id = create_ingredient_bypassing_validation(name: "onion", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "onion", created_at: 1.day.ago)

    recipe = recipes(:one)
    recipe_ingredient = RecipeIngredient.create!(
      recipe: recipe,
      ingredient_id: duplicate_id,
      numerator: 1,
      denominator: 1
    )

    DuplicateIngredientConsolidationJob.perform_now

    recipe_ingredient.reload
    assert_equal canonical_id, recipe_ingredient.ingredient_id
  end

  def test_migrates_shopping_list_items_to_canonical
    canonical_id = create_ingredient_bypassing_validation(name: "garlic", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "garlic", created_at: 1.day.ago)

    shopping_list = shopping_lists(:one)
    shopping_list_item = ShoppingListItem.create!(
      shopping_list: shopping_list,
      ingredient_id: duplicate_id,
      name: "garlic"
    )

    DuplicateIngredientConsolidationJob.perform_now

    shopping_list_item.reload
    assert_equal canonical_id, shopping_list_item.ingredient_id
  end

  def test_migrates_archived_shopping_list_items_to_canonical
    canonical_id = create_ingredient_bypassing_validation(name: "pepper", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "pepper", created_at: 1.day.ago)

    shopping_list = shopping_lists(:one)
    shopping_list_item = ShoppingListItem.create!(
      shopping_list: shopping_list,
      ingredient_id: duplicate_id,
      name: "pepper"
    )
    shopping_list_item.archive!

    DuplicateIngredientConsolidationJob.perform_now

    shopping_list_item.reload
    assert_equal canonical_id, shopping_list_item.ingredient_id
  end

  def test_migrates_offering_ingredients_to_canonical
    canonical_id = create_ingredient_bypassing_validation(name: "salt", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "salt", created_at: 1.day.ago)

    offering = offerings(:grilled_chicken_veggies)
    offering_ingredient = OfferingIngredient.create!(
      offering: offering,
      ingredient_id: duplicate_id,
      numerator: 1,
      denominator: 1
    )

    DuplicateIngredientConsolidationJob.perform_now

    offering_ingredient.reload
    assert_equal canonical_id, offering_ingredient.ingredient_id
  end

  def test_migrates_user_ingredient_preferences_without_conflict
    user = users(:one)
    canonical_id = create_ingredient_bypassing_validation(name: "basil", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "basil", created_at: 1.day.ago)

    preference = UserIngredientPreference.create!(
      user: user,
      ingredient_id: duplicate_id,
      preferred_brand: "Brand A",
      usage_count: 5,
      last_used_at: 1.day.ago
    )

    DuplicateIngredientConsolidationJob.perform_now

    preference.reload
    assert_equal canonical_id, preference.ingredient_id
    assert_equal "Brand A", preference.preferred_brand
    assert_equal 5, preference.usage_count
  end

  def test_merges_user_ingredient_preferences_when_conflict
    user = users(:one)
    canonical_id = create_ingredient_bypassing_validation(name: "oregano", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "oregano", created_at: 1.day.ago)

    # User has preferences for both
    canonical_pref = UserIngredientPreference.create!(
      user: user,
      ingredient_id: canonical_id,
      preferred_brand: "Brand A",
      usage_count: 5,
      last_used_at: 3.days.ago
    )

    duplicate_pref = UserIngredientPreference.create!(
      user: user,
      ingredient_id: duplicate_id,
      preferred_brand: "Brand B",
      usage_count: 10,
      last_used_at: 1.day.ago
    )

    DuplicateIngredientConsolidationJob.perform_now

    canonical_pref.reload
    assert_equal 15, canonical_pref.usage_count # 5 + 10
    assert_equal "Brand B", canonical_pref.preferred_brand # Higher usage
    assert_equal duplicate_pref.last_used_at.to_i, canonical_pref.last_used_at.to_i # Most recent
    assert_nil UserIngredientPreference.find_by(id: duplicate_pref.id)
  end

  def test_does_not_consolidate_different_packaging_forms
    fresh = Ingredient.create!(name: "tomato", packaging_form: "fresh", created_at: 2.days.ago)
    canned = Ingredient.create!(name: "tomato", packaging_form: "canned", created_at: 1.day.ago)

    DuplicateIngredientConsolidationJob.perform_now

    assert_not_nil Ingredient.find_by(id: fresh.id)
    assert_not_nil Ingredient.find_by(id: canned.id)
  end

  def test_does_not_consolidate_different_preparation_styles
    whole = Ingredient.create!(name: "onion", preparation_style: "whole", created_at: 2.days.ago)
    diced = Ingredient.create!(name: "onion", preparation_style: "diced", created_at: 1.day.ago)

    DuplicateIngredientConsolidationJob.perform_now

    assert_not_nil Ingredient.find_by(id: whole.id)
    assert_not_nil Ingredient.find_by(id: diced.id)
  end

  def test_handles_no_duplicates_gracefully
    assert_logs_match(/INGREDIENT_CONSOLIDATION: No duplicate ingredients found/) do
      DuplicateIngredientConsolidationJob.perform_now
    end
  end

  def test_logs_consolidation_statistics
    canonical_id = create_ingredient_bypassing_validation(name: "thyme", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "thyme", created_at: 1.day.ago)

    assert_logs_match(/INGREDIENT_CONSOLIDATION: Successfully consolidated: 1 groups/) do
      DuplicateIngredientConsolidationJob.perform_now
    end
  end

  def test_preserves_canonical_ingredient_category
    category = ingredient_categories(:fresh_produce)
    canonical_id = create_ingredient_bypassing_validation(name: "rosemary", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "rosemary", created_at: 1.day.ago)

    # Update canonical to have category
    Ingredient.where(id: canonical_id).update_all(ingredient_category_id: category.id)

    DuplicateIngredientConsolidationJob.perform_now

    canonical = Ingredient.find(canonical_id)
    assert_equal category.id, canonical.ingredient_category_id
  end

  def test_handles_multiple_duplicates_in_same_group
    canonical_id = create_ingredient_bypassing_validation(name: "cumin", created_at: 3.days.ago)
    duplicate1_id = create_ingredient_bypassing_validation(name: "cumin", created_at: 2.days.ago)
    duplicate2_id = create_ingredient_bypassing_validation(name: "cumin", created_at: 1.day.ago)

    DuplicateIngredientConsolidationJob.perform_now

    assert_not_nil Ingredient.find_by(id: canonical_id)
    assert_nil Ingredient.find_by(id: duplicate1_id)
    assert_nil Ingredient.find_by(id: duplicate2_id)
  end

  def test_handles_case_insensitive_duplicates
    canonical_id = create_ingredient_bypassing_validation(name: "Parsley", created_at: 2.days.ago)
    duplicate_id = create_ingredient_bypassing_validation(name: "PARSLEY", created_at: 1.day.ago)

    DuplicateIngredientConsolidationJob.perform_now

    # Both should be downcased to "parsley" by model callback
    # Only one should remain
    parsley_count = Ingredient.where("LOWER(name) = ?", "parsley").count
    assert_equal 1, parsley_count
  end

  private

  # Helper to create ingredient bypassing unique constraint validation
  def create_ingredient_bypassing_validation(name:, packaging_form: nil, preparation_style: nil, created_at: Time.current)
    sql = <<-SQL
      INSERT INTO ingredients (name, packaging_form, preparation_style, created_at, updated_at)
      VALUES (
        '#{ActiveRecord::Base.connection.quote_string(name.downcase)}',
        #{packaging_form ? "'#{ActiveRecord::Base.connection.quote_string(packaging_form)}'" : 'NULL'},
        #{preparation_style ? "'#{ActiveRecord::Base.connection.quote_string(preparation_style)}'" : 'NULL'},
        '#{created_at.to_fs(:db)}',
        '#{Time.current.to_fs(:db)}'
      )
      RETURNING id
    SQL

    result = ActiveRecord::Base.connection.execute(sql)
    result.first['id'].to_i
  end

  def assert_logs_match(regex)
    logs = capture_log_output do
      yield
    end
    assert_match regex, logs, "Expected logs to match #{regex.inspect}"
  end

  def capture_log_output
    original_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)

    yield

    log_output.string
  ensure
    Rails.logger = original_logger
  end
end
