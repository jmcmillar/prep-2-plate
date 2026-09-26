require "test_helper"

class OrphanedIngredientCleanupJobTest < ActiveJob::TestCase
  def test_removes_ingredients_not_associated_with_any_recipe_ingredients
    orphaned_ingredient = ingredients(:destroyable)
    assert_not_nil orphaned_ingredient

    OrphanedIngredientCleanupJob.perform_now

    assert_nil Ingredient.find_by(id: orphaned_ingredient.id)
  end

  def test_does_not_remove_ingredients_associated_with_recipe_ingredients
    ingredient_one = ingredients(:one)
    ingredient_two = ingredients(:two)

    OrphanedIngredientCleanupJob.perform_now

    assert_not_nil Ingredient.find_by(id: ingredient_one.id)
    assert_not_nil Ingredient.find_by(id: ingredient_two.id)
  end

  def test_keeps_ingredients_referenced_outside_recipes
    on_offering = offering_ingredient_for(Ingredient.create!(name: "offering only ingredient")).ingredient
    on_archived_list_item = Ingredient.create!(name: "shopping list only ingredient")
    ShoppingListItem.create!(shopping_list: shopping_lists(:one), name: "list item", ingredient: on_archived_list_item, archived_at: 1.day.ago)
    on_preference = Ingredient.create!(name: "preference only ingredient")
    UserIngredientPreference.create!(user: users(:one), ingredient: on_preference, preferred_brand: "Brand")
    orphan = Ingredient.create!(name: "truly orphaned ingredient")

    OrphanedIngredientCleanupJob.perform_now

    assert Ingredient.exists?(on_offering.id)
    assert Ingredient.exists?(on_archived_list_item.id)
    assert Ingredient.exists?(on_preference.id)
    assert_not Ingredient.exists?(orphan.id)
  end

  def test_logs_the_number_of_orphaned_ingredients_removed
    orphaned = Ingredient.create!(name: "orphaned test ingredient")

    assert_logs_match(/OrphanedIngredientCleanupJob: Removed \d+ orphaned ingredient\(s\)/) do
      OrphanedIngredientCleanupJob.perform_now
    end
  end

  private

  def offering_ingredient_for(ingredient)
    offerings(:grilled_chicken_veggies).offering_ingredients.create!(ingredient: ingredient, numerator: 1, denominator: 1)
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
