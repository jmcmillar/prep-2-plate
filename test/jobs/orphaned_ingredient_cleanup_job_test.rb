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

  def test_logs_the_number_of_orphaned_ingredients_removed
    orphaned = Ingredient.create!(name: "orphaned test ingredient")

    assert_logs_match(/OrphanedIngredientCleanupJob: Removed \d+ orphaned ingredient\(s\)/) do
      OrphanedIngredientCleanupJob.perform_now
    end
  end

  private

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
