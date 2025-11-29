class OrphanedRecipeImportCleanupJob < ApplicationJob
  queue_as :default

  def perform
    RecipeImport.left_joins(:recipes)
      .where(recipes: { id: nil })
      .destroy_all
    Rails.logger.info "OrphanedRecipeImportCleanupJob: Removed orphaned recipe imports"
  end
end
