class OrphanedIngredientCleanupJob < ApplicationJob
  queue_as :default

  def perform
    # Find and delete ingredients that have no associated recipe_ingredients
    orphaned_ingredients = Ingredient.left_joins(:recipe_ingredients)
                                     .where(recipe_ingredients: { id: nil })
                                     .destroy_all

    Rails.logger.info "OrphanedIngredientCleanupJob: Removed #{orphaned_ingredients.size} orphaned ingredient(s)"
  end
end
