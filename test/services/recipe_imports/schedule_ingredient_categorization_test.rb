require "test_helper"

class RecipeImports::ScheduleIngredientCategorizationTest < ActiveJob::TestCase
  def test_enqueues_delayed_categorization_when_api_key_is_set
    with_api_key("test-key") do
      freeze_time do
        RecipeImports::ScheduleIngredientCategorization.call

        assert_enqueued_with(job: CategorizeIngredientsJob, at: 2.minutes.from_now)
      end
    end
  end

  def test_skips_when_api_key_is_missing
    with_api_key(nil) do
      assert_no_enqueued_jobs { RecipeImports::ScheduleIngredientCategorization.call }
    end
  end

  private

  def with_api_key(value)
    original = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = value
    yield
  ensure
    ENV["ANTHROPIC_API_KEY"] = original
  end
end
