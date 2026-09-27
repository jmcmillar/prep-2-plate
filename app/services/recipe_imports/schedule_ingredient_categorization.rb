# Queues ingredient categorization shortly after an import so new ingredients
# are grouped on shopping lists without waiting for the nightly run. The delay
# lets imports made close together share one run.
class RecipeImports::ScheduleIngredientCategorization
  include Service

  DELAY = 2.minutes

  def initialize(job: CategorizeIngredientsJob)
    @job = job
  end

  def call
    return unless ENV["ANTHROPIC_API_KEY"].present?

    @job.set(wait: DELAY).perform_later
  end
end
